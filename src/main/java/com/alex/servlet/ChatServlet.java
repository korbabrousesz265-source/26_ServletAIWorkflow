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
        req.setAttribute("templates", nodeMarketService.getAllNodes());

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

        if (userText != null && !userText.isEmpty() && promptIds != null) {
            String currentText = userText;
            java.util.List<String> trajectoryLogs = new java.util.ArrayList<>();
            String finalResult = currentText;

            for (int i = 0; i < promptIds.length; i++) {
                String pid = promptIds[i];
                // 1. PPT 节点拦截逻辑 (本地沙箱，不消耗 Token)
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
                        trajectoryLogs.add("🎁 【PPT 渲染引擎】已成功拦截 JSON，为您唤起下载 (本地沙箱执行, 0 Token)");

                        // 记录本地节点日志
                        WfHistoryLog log = new WfHistoryLog();
                        log.setUserId(userId);
                        log.setWorkflowName("AI 自动化流转");
                        log.setNodeName("导出为 PowerPoint");
                        log.setTokenUsed(0);
                        log.setDuration(120); // 虚拟极速耗时
                        logService.insertLog(log); // 👑 使用 Service 提交日志
                    }
                    continue;
                }

                // 2. AI 节点流转
                WfNodeMarket nodeInfo = nodeMarketService.getNodeById(Integer.parseInt(pid));
                if (nodeInfo != null) {
                    String systemPrompt = nodeInfo.getSystemPrompt();

                    // 🔧 PPT 智能注入：如果下一个节点是 PPT，自动注入模板结构
                    if (i + 1 < promptIds.length && "-1".equals(promptIds[i + 1])) {
                        try {
                            String templatePath = "E:/template.pptx";
                            java.io.File templateFile = new java.io.File(templatePath);
                            if (templateFile.exists()) {
                                com.google.gson.JsonObject structure = com.alex.utils.PPTUtil.extractSlideStructure(templatePath);
                                String structureStr = structure.toString();
                                systemPrompt = systemPrompt + "\n\n【重要：PPT 模板结构】\n"
                                    + "当前工作流的最终输出是一个 PowerPoint 文件。模板中每页幻灯片的占位文字如下（JSON格式）：\n"
                                    + structureStr + "\n"
                                    + "你必须输出一个 JSON 对象，格式要求：\n"
                                    + "1. 顶层 key 为 slide_1, slide_2... 与模板页数一一对应\n"
                                    + "2. 每页的 value 也是一个 JSON 对象，其 key 必须使用上面模板结构中对应的占位文字（含 _1, _2 后缀），value 是你要替换成的新内容\n"
                                    + "3. 例如模板 slide_1 有 \"个人述职报告_1\"，你应该输出 {\"slide_1\": {\"个人述职报告_1\": \"替换后的新标题\"}}\n"
                                    + "4. 只输出 JSON，不要包含任何其他文字或 markdown 标记！";
                                System.out.println("🔧 [ChatServlet] 已向 AI 节点 \"" + nodeInfo.getName() + "\" 注入 PPT 模板结构 (共 " + structure.keySet().size() + " 页)");
                            } else {
                                System.out.println("⚠️ [ChatServlet] PPT 模板文件不存在，无法注入结构: " + templatePath);
                            }
                        } catch (Exception e) {
                            System.err.println("⚠️ [ChatServlet] 注入 PPT 模板结构失败: " + e.getMessage());
                        }
                    }

                    // ⏱️ 开启毫秒级测速
                    long startTime = System.currentTimeMillis();

                    // 👑 架构师核心：动态密钥路由策略
                    // 优先级 1：读取用户自己在数据库里配置的私人 Key
                    String finalApiKey = null;
                    com.alex.pojo.SysApiKey userKey = apiKeyService.getApiKeyByUserId(userId);
                    if (userKey != null && userKey.getDeepseekKey() != null && !userKey.getDeepseekKey().isEmpty()) {
                        finalApiKey = userKey.getDeepseekKey();
                    }
                    // 优先级 2：如果用户没配置，读取服务器操作系统里的环境变量作为兜底系统 Key
                    if (finalApiKey == null || finalApiKey.isEmpty()) {
                        finalApiKey = System.getenv("SYS_AI_API_KEY");
                    }

                    // ⏱️ 开启毫秒级测速
//                    long startTime = System.currentTimeMillis();

                    // 传入动态选定的 Key
                    JsonObject aiResult = callRealAiApi(currentText, systemPrompt, finalApiKey);

                    // 🐛 修复报错的核心：从 JsonObject 中拆解文本和消耗！
                    String aiResponse = aiResult.get("content").getAsString();
                    int tokens = aiResult.get("tokens").getAsInt();
                    int duration = (int) (System.currentTimeMillis() - startTime);

                    // 💾 将实际消耗持久化到数据库
                    WfHistoryLog log = new WfHistoryLog();
                    log.setUserId(userId);
                    log.setWorkflowName("AI 自动化流转");
                    log.setNodeName(nodeInfo.getName());
                    log.setTokenUsed(tokens);
                    log.setDuration(duration);
                    logService.insertLog(log); // 👑 使用 Service 提交日志

                    trajectoryLogs.add("✅ 【" + nodeInfo.getName() + "】执行完毕 [耗时: " + duration + "ms, 消耗: " + tokens + " Token]：\n" + aiResponse);
                    currentText = aiResponse;
                    finalResult = aiResponse;
                }
            }

            req.setAttribute("trajectoryLogs", trajectoryLogs);
            req.setAttribute("finalResult", finalResult);
            // 同样用 Service 把供下次拖拽的左侧节点列表传回前端
            req.setAttribute("templates", nodeMarketService.getAllNodes());
        }

        req.getRequestDispatcher("/workflow.jsp").forward(req, resp);
    }
    // 👑 改造大模型调用底层：解析 JSON 中的 usage 字段，返回耗费 Token
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

            HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(30)).build();
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
}