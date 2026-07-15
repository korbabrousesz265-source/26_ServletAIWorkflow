package com.alex.servlet;

import com.alex.mapper.WfHistoryLogMapper;
import com.alex.mapper.WfNodeMarketMapper;
import com.alex.pojo.WfHistoryLog;
import com.alex.pojo.WfNodeMarket;
import com.alex.service.WfHistoryLogService;
import com.alex.service.WfNodeMarketService;
import com.alex.service.SysApiKeyService;
import com.alex.service.impl.WfHistoryLogServiceImpl;
import com.alex.service.impl.WfNodeMarketServiceImpl;
import com.alex.service.impl.SysApiKeyServiceImpl;
import com.alex.utils.MyBatisUtil;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

//    private static final String API_KEY = "sk-f7038d41ff93462caa28d588ae701864";
    private static final String API_URL = "https://api.deepseek.com/chat/completions";
    // 👑 呼叫节点市场主厨
    private WfNodeMarketService nodeMarketService = new WfNodeMarketServiceImpl();
    // 👑 呼叫计费与审计主厨
    private WfHistoryLogService logService = new WfHistoryLogServiceImpl();
    // 👑 呼叫 API Key 主厨
    private SysApiKeyService apiKeyService = new SysApiKeyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 极其纯净的一行获取数据代码
        req.setAttribute("templates", nodeMarketService.getApprovedNodes());

        // 🔑 检查用户是否已配置 API Key
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId != null && userId > 0) {
            com.alex.pojo.SysApiKey key = apiKeyService.getApiKeyByUserId(userId);
            boolean openaiEmpty = key == null || key.getOpenaiKey() == null || key.getOpenaiKey().isEmpty();
            boolean deepseekEmpty = key == null || key.getDeepseekKey() == null || key.getDeepseekKey().isEmpty();
            if (openaiEmpty && deepseekEmpty) {
                req.setAttribute("showApiKeyWarning", true);
            }
        }

        req.getRequestDispatcher("/workflow.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String userText = req.getParameter("userText");
        String[] promptIds = req.getParameterValues("promptIds");

        // 👑 获取当前登录用户 ID (访客为 0)
        Integer userId = (Integer) req.getSession().getAttribute("userId");
        if (userId == null) userId = 0;

        // 👑 检查是否为 AJAX 请求（返回 JSON 供画布前端使用）
        boolean isAjax = "true".equals(req.getParameter("ajax"));

        // 用于 AJAX 模式下收集每个节点的执行结果
        com.google.gson.JsonArray nodeResults = new com.google.gson.JsonArray();

        if (userText != null && !userText.isEmpty() && promptIds != null) {
            String currentText = userText;
            java.util.List<String> trajectoryLogs = new java.util.ArrayList<>();

            // 👑 1. 接收前端传来的 DAG 拓扑层级 (这里简化为接收特殊的 promptIds 格式，前端会将同一层的用逗号拼接)
            // 例如前端发来: promptIds = ["1,-2", "3"] 代表第一层并联执行 1 和 -2，第二层执行 3
            for (int stageIndex = 0; stageIndex < promptIds.length; stageIndex++) {
                String[] parallelNodeIds = promptIds[stageIndex].split(",");

                // 如果当前层只有一个节点（串行）
                if (parallelNodeIds.length == 1) {
                    currentText = executeSingleNode(parallelNodeIds[0], currentText, userId, trajectoryLogs, nodeResults, stageIndex, req);
                }
                // 👑 2. 如果当前层有多个节点（并联并发执行）
                // 👑 2. 如果当前层有多个节点（并联并发执行）
                else {
                    trajectoryLogs.add("⚡ 【引擎触发】：启动多线程并联执行...");
                    java.util.List<java.util.concurrent.CompletableFuture<String>> futures = new java.util.ArrayList<>();

                    // 为每一个并联节点分配一个异步线程
                    for (String pid : parallelNodeIds) {

                        // 🚀 核心修复：为 Lambda 表达式创建绝对不可变的 final 变量快照
                        final String finalPid = pid;
                        final String finalInput = currentText;
                        final int finalIdx = stageIndex;
                        final Integer finalUserId = userId;
                        final HttpServletRequest finalReq = req;

                        java.util.concurrent.CompletableFuture<String> future = java.util.concurrent.CompletableFuture.supplyAsync(() -> {
                            // 使用 final 副本调用单节点执行方法
                            return executeSingleNode(finalPid, finalInput, finalUserId, trajectoryLogs, nodeResults, finalIdx, finalReq);
                        });
                        futures.add(future);
                    }

                    // 👑 3. 阻塞主线程，等待所有并联节点执行完毕 (Join)
                    java.util.concurrent.CompletableFuture.allOf(futures.toArray(new java.util.concurrent.CompletableFuture[0])).join();

                    // 👑 4. 汇总所有并联节点的输出，作为超级上下文传递给下一层
                    StringBuilder mergedOutput = new StringBuilder("【上游多源并联数据汇总】：\n");
                    for (int i = 0; i < futures.size(); i++) {
                        try {
                            mergedOutput.append("--- 数据源 ").append(i + 1).append(" ---\n");
                            mergedOutput.append(futures.get(i).get()).append("\n\n");
                        } catch (Exception e) { e.printStackTrace(); }
                    }
                    currentText = mergedOutput.toString();
                    trajectoryLogs.add("✅ 【并联层执行完毕】：已将多源数据合并，下发至下一层。");
                }
            }

            req.setAttribute("trajectoryLogs", trajectoryLogs);
            req.setAttribute("finalResult", currentText);
            req.setAttribute("templates", nodeMarketService.getApprovedNodes());
        }

        // 👑 AJAX 模式：返回 JSON，不走 JSP 渲染
        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            com.google.gson.JsonObject responseJson = new com.google.gson.JsonObject();
            responseJson.add("nodeResults", nodeResults);
            responseJson.addProperty("finalResult", req.getAttribute("finalResult") != null
                    ? req.getAttribute("finalResult").toString() : "");
            responseJson.addProperty("autoTriggerPPT", req.getAttribute("autoTriggerPPT") != null
                    ? req.getAttribute("autoTriggerPPT").toString() : "");
            java.io.PrintWriter out = resp.getWriter();
            out.write(responseJson.toString());
            out.flush();
            return; // 不执行 forward，直接结束
        }

        req.getRequestDispatcher("/workflow.jsp").forward(req, resp);
    }

    /**
     * 👑 核心单节点执行引擎 (支持 DAG 多线程并发调用)
     *
     * @param pid             当前需要执行的节点 ID
     * @param currentText     流入该节点的上游上下文文本
     * @param userId          当前操作的用户 ID
     * @param trajectoryLogs  全局运行轨迹日志 (需保证线程安全)
     * @param nodeResults     全局节点运行结果收集器 (需保证线程安全)
     * @param nodeIndex       当前节点所在的层级索引 (用于前端展示)
     * @param req             HTTP 请求对象 (用于回传特殊指令如 PPT 触发)
     * @return                该节点执行完毕后向外流出的文本结果
     */
    private String executeSingleNode(String pid, String currentText, Integer userId,
                                     java.util.List<String> trajectoryLogs,
                                     com.google.gson.JsonArray nodeResults,
                                     int nodeIndex,
                                     HttpServletRequest req) {

        com.google.gson.JsonObject nodeResult = new com.google.gson.JsonObject();
        nodeResult.addProperty("nodeIndex", nodeIndex);
        nodeResult.addProperty("nodeId", pid);

        // ========================================================
        // 插件节点 1：PPT 渲染引擎 (本地沙箱)
        // ========================================================
        if ("-1".equals(pid)) {
            String jsonPayload = currentText;
            if (jsonPayload != null) {
                int start = jsonPayload.indexOf('{');
                int end = jsonPayload.lastIndexOf('}');
                if (start != -1 && end != -1 && start <= end) {
                    jsonPayload = jsonPayload.substring(start, end + 1);
                }
            }

            if (jsonPayload != null && jsonPayload.trim().startsWith("{")) {
                req.setAttribute("autoTriggerPPT", jsonPayload);

                // 🔒 多线程写锁：保证并发添加日志时不报错
                synchronized (trajectoryLogs) {
                    trajectoryLogs.add("🎁 【PPT 渲染引擎】已成功拦截 JSON，为您唤起下载 (本地沙箱执行, 0 Token)");
                }

                WfHistoryLog log = new WfHistoryLog();
                log.setUserId(userId);
                log.setWorkflowName("AI 自动化流转");
                log.setNodeName("导出为 PowerPoint");
                log.setTokenUsed(0);
                log.setDuration(120);
                logService.insertLog(log);

                nodeResult.addProperty("nodeName", "导出为 PowerPoint");
                nodeResult.addProperty("status", "done");
                nodeResult.addProperty("output", "PPT 渲染成功，正在下载...");
                nodeResult.addProperty("duration", 120);
                nodeResult.addProperty("tokens", 0);
                nodeResult.addProperty("isPPT", true);
                nodeResult.addProperty("pptData", jsonPayload);
            } else {
                nodeResult.addProperty("nodeName", "导出为 PowerPoint");
                nodeResult.addProperty("status", "error");
                nodeResult.addProperty("output", "未检测到有效的 JSON 数据，无法生成 PPT");
                nodeResult.addProperty("duration", 0);
                nodeResult.addProperty("tokens", 0);
                nodeResult.addProperty("isPPT", true);
            }

            // 🔒 多线程写锁：安全追加结果
            synchronized (nodeResults) { nodeResults.add(nodeResult); }
            return currentText; // PPT 节点不改变文本，原样传出
        }

        // ========================================================
        // 插件节点 2：实时联网检索引擎 (RAG 并联增强)
        // ========================================================
        else if ("-2".equals(pid)) {
            long searchStartTime = System.currentTimeMillis();

            // 智能 Query 提取：防止上游文章过长，截取核心
            String searchQuery = currentText;
            if (currentText.length() > 100) {
                searchQuery = currentText.substring(0, 100).replace("\n", " ") + "...";
            }

            // 执行外部检索 API
            String searchResult = callWebSearchApi(searchQuery);
            int searchDuration = (int) (System.currentTimeMillis() - searchStartTime);

            // RAG 并联拼接
            String augmentedText = "【上游链路传递的核心上下文】：\n" + currentText +
                    "\n\n=================================\n\n" +
                    "【联网插件为您实时挂载的最新数据 (RAG)】：\n" + searchResult;

            WfHistoryLog log = new WfHistoryLog();
            log.setUserId(userId);
            log.setWorkflowName("AI 自动化流转");
            log.setNodeName("实时联网检索 (RAG)");
            log.setTokenUsed(0);
            log.setDuration(searchDuration);
            logService.insertLog(log);

            nodeResult.addProperty("nodeName", "实时联网检索 (RAG)");
            nodeResult.addProperty("status", "done");
            nodeResult.addProperty("output", "🔍 正在以上游文意提取 Query 检索全网...\n\n✅ 检索成功，数据源预览：\n" + searchResult);
            nodeResult.addProperty("duration", searchDuration);
            nodeResult.addProperty("tokens", 0);

            synchronized (trajectoryLogs) {
                trajectoryLogs.add("✅ 【实时联网检索】执行完毕，成功实现上下文增强拼接。");
            }
            synchronized (nodeResults) { nodeResults.add(nodeResult); }

            return augmentedText; // 返回挂载了全网数据的新上下文
        }

        // ========================================================
        // 核心 AI 算力节点流转
        // ========================================================
        else {
            WfNodeMarket nodeInfo = nodeMarketService.getNodeById(Integer.parseInt(pid));
            if (nodeInfo != null) {
                nodeResult.addProperty("nodeName", nodeInfo.getName());
                String systemPrompt = nodeInfo.getSystemPrompt();

                // 计时开始
                long startTime = System.currentTimeMillis();

                // 动态获取加密的 BYOK 私钥或系统公钥
                String finalApiKey = null;
                com.alex.pojo.SysApiKey userKey = apiKeyService.getApiKeyByUserId(userId);
                if (userKey != null && userKey.getDeepseekKey() != null && !userKey.getDeepseekKey().isEmpty()) {
                    finalApiKey = userKey.getDeepseekKey();
                }
                if (finalApiKey == null || finalApiKey.isEmpty()) {
                    finalApiKey = System.getenv("SYS_AI_API_KEY");
                }

                // 核心：分发给外部大模型
                JsonObject aiResult = callRealAiApi(currentText, systemPrompt, finalApiKey);

                String aiResponse = aiResult.get("content").getAsString();
                int tokens = aiResult.get("tokens").getAsInt();
                int duration = (int) (System.currentTimeMillis() - startTime);

                // 日志落盘
                WfHistoryLog log = new WfHistoryLog();
                log.setUserId(userId);
                log.setWorkflowName("AI 自动化流转");
                log.setNodeName(nodeInfo.getName());
                log.setTokenUsed(tokens);
                log.setDuration(duration);
                logService.insertLog(log);

                synchronized (trajectoryLogs) {
                    trajectoryLogs.add("✅ 【" + nodeInfo.getName() + "】执行完毕 [耗时: " + duration + "ms, 消耗: " + tokens + " Token]：\n" + aiResponse);
                }

                boolean isError = aiResponse.contains("AI 接口调用失败") || aiResponse.contains("系统异常");
                nodeResult.addProperty("status", isError ? "error" : "done");
                nodeResult.addProperty("output", aiResponse);
                nodeResult.addProperty("duration", duration);
                nodeResult.addProperty("tokens", tokens);

                synchronized (nodeResults) { nodeResults.add(nodeResult); }
                return aiResponse; // 输出 AI 提炼后的新内容

            } else {
                // 节点已被下架或不存在的防御处理
                nodeResult.addProperty("nodeName", "未知节点 (ID:" + pid + ")");
                nodeResult.addProperty("status", "error");
                nodeResult.addProperty("output", "节点不存在或已被系统下架");
                nodeResult.addProperty("duration", 0);
                nodeResult.addProperty("tokens", 0);

                synchronized (nodeResults) { nodeResults.add(nodeResult); }
                return currentText; // 发生错误，原文直通，不阻断整体管网
            }
        }
    }

    // 👑 改造：接收外部传入的动态 apiKey，而不是用全局静态变量
    private JsonObject callRealAiApi(String userText, String systemPrompt, String apiKey) {

        JsonObject result = new JsonObject();
        result.addProperty("content", "AI 接口调用失败");
        result.addProperty("tokens", 0); // 默认 0 Token

        // 如果连兜底密钥都没有，直接拦截
        if (apiKey == null || apiKey.trim().isEmpty()) {
            result.addProperty("content", "系统或用户未配置 API Key，请先前往个人中心配置！");
            return result;
        }

        try {
            JsonObject requestBody = new JsonObject();
            requestBody.addProperty("model", "deepseek-chat");

            JsonArray messages = new JsonArray();
            JsonObject sysMsg = new JsonObject();
            sysMsg.addProperty("role", "system");
            sysMsg.addProperty("content", systemPrompt);
            messages.add(sysMsg);

            JsonObject usrMsg = new JsonObject();
            usrMsg.addProperty("role", "user");
            usrMsg.addProperty("content", userText);
            messages.add(usrMsg);

            requestBody.add("messages", messages);
            requestBody.addProperty("temperature", 0.6);
            requestBody.addProperty("max_tokens", 8192);

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("Content-Type", "application/json")
                    // 👑 核心：使用传入的动态密钥
                    .header("Authorization", "Bearer " + apiKey)
                    .timeout(Duration.ofMinutes(5))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody.toString(), java.nio.charset.StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                JsonObject respJson = JsonParser.parseString(response.body()).getAsJsonObject();
                // 1. 提取回答文本
                String content = respJson.getAsJsonArray("choices").get(0).getAsJsonObject()
                        .getAsJsonObject("message").get("content").getAsString();
                // 2. 👑 核心：提取 Token 真实消耗
                int totalTokens = respJson.getAsJsonObject("usage").get("total_tokens").getAsInt();

                result.addProperty("content", content);
                result.addProperty("tokens", totalTokens);
            } else {
                result.addProperty("content", "AI 接口调用失败，状态码：" + response.statusCode());
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.addProperty("content", "系统异常：无法连接到 AI 服务器 (" + e.getMessage() + ")");
        }
        return result;
    }

    /**
     * 👑 真实的外部检索引擎 (基于 Wikipedia 开放 API - 永久免费，无极量限制)
     */
    private String callWebSearchApi(String query) {
        try {
            // 1. 构建维基百科 API 请求 URL (使用 UTF-8 编码搜索词)
            String encodedQuery = java.net.URLEncoder.encode(query, "UTF-8");
            // action=query & list=search 意思是执行全站搜索
            String wikiApiUrl = "https://zh.wikipedia.org/w/api.php?action=query&list=search&srsearch="
                    + encodedQuery + "&utf8=&format=json";

            // 2. 发起原生的 HTTP GET 请求
            // 2. 发起原生的 HTTP GET 请求 (👑 加上代理穿透防火墙！)
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .proxy(java.net.ProxySelector.of(new java.net.InetSocketAddress("127.0.0.1", 7890))) // 🚀 确保这里的 7890 是你本地梯子的真实端口
                    .build();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(wikiApiUrl))
                    // 🚀 核心修复：添加 User-Agent 伪装！维基百科强制要求必须有身份标识，否则直接 403 封杀。
                    .header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 WfEngine/1.0")
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            // 3. 解析返回的 JSON 数据
            if (response.statusCode() == 200) {
                com.google.gson.JsonObject respJson = com.google.gson.JsonParser.parseString(response.body()).getAsJsonObject();
                com.google.gson.JsonObject queryObj = respJson.getAsJsonObject("query");
                com.google.gson.JsonArray searchResults = queryObj.getAsJsonArray("search");

                if (searchResults == null || searchResults.size() == 0) {
                    return "【检索结果】：维基百科全库中未找到与 [" + query + "] 相关的确切条目。";
                }

                // 4. 拼装前 3 条搜索结果作为 RAG 超级上下文
                StringBuilder realContext = new StringBuilder("[维基百科实时检索数据]\n");
                int limit = Math.min(searchResults.size(), 3);

                for (int i = 0; i < limit; i++) {
                    com.google.gson.JsonObject item = searchResults.get(i).getAsJsonObject();
                    String title = item.has("title") ? item.get("title").getAsString() : "无标题";
                    String snippet = item.has("snippet") ? item.get("snippet").getAsString() : "无摘要";

                    // 👑 极客细节：维基百科的 snippet 带有 <span class="searchmatch"> 等 HTML 标签，
                    // 我们用正则表达式 <[^>]*> 将其全部清洗掉，只留纯文本给大模型，节省 Token！
                    String cleanSnippet = snippet.replaceAll("<[^>]*>", "");

                    realContext.append(i + 1).append(". 词条：").append(title).append("\n");
                    realContext.append("   摘要：").append(cleanSnippet).append("...\n\n");
                }
                return realContext.toString();
            } else {
                return "【联网检索失败】：维基百科服务器返回状态码 " + response.statusCode();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "【联网检索异常】：网络请求中断 (" + e.getMessage() + ")";
        }
    }


}