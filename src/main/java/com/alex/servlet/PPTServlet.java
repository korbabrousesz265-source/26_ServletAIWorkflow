package com.alex.servlet;

import com.alex.utils.PPTUtil;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;

@WebServlet("/pptServlet")
public class PPTServlet extends BaseServlet {

    /**
     * 唯一渲染引擎出口：接受 JSON，返回组装好的 PPT
     */
    protected String export(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            request.setCharacterEncoding("UTF-8"); // 这行留着

            // 👑 架构师绝杀：解码前端传来的双重 URL 编码，彻底防御 Tomcat 乱码机制！
            String rawData = request.getParameter("pptData");
            String aiJsonString = java.net.URLDecoder.decode(rawData, "UTF-8");

            if (aiJsonString == null || aiJsonString.trim().isEmpty()) {
                response.sendError(400, "❌ 错误：PPT 数据不能为空！");
                return null;
            }

            JsonObject aiJsonData;
            try {
                aiJsonData = JsonParser.parseString(aiJsonString).getAsJsonObject();
            } catch (Exception e) {
                System.err.println("❌ PPT 节点接收到的非法数据: " + aiJsonString);
                response.sendError(400, "❌ 节点链路错误：PPT 渲染节点必须接收合法的 JSON 数据！");
                return null;
            }

            // 读取底层模板
            String templatePath = "E:/template.pptx";
            File templateFile = new File(templatePath);
            if (!templateFile.exists()) {
                response.sendError(500, "❌ 严重错误：找不到底层 PPT 模板文件！路径：" + templatePath);
                return null;
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.presentationml.presentation");
            String filename = "AI_Generated_Presentation.pptx";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            // 👑 智能路由升级：强行扒掉外壳（但绝不误杀 slide_N 格式的 key）
            JsonObject actualPayload = aiJsonData;
            if (aiJsonData.size() == 1) {
                String wrapperKey = aiJsonData.keySet().iterator().next();
                // 🔧 修复：如果唯一的 key 本身就是 slide_N 格式，说明没有被包裹，不要剥壳！
                if (!wrapperKey.matches("(?i)slide_\\d+") && aiJsonData.get(wrapperKey).isJsonObject()) {
                    actualPayload = aiJsonData.getAsJsonObject(wrapperKey);
                }
            }

            System.out.println("🚀 [PPT引擎] ========== PPT 渲染诊断开始 ==========");
            System.out.println("📥 [PPT引擎] 原始 JSON keys: " + aiJsonData.keySet());
            System.out.println("📥 [PPT引擎] 原始 JSON size: " + aiJsonData.size());
            System.out.println("🎯 [PPT引擎] 实际传入 Payload keys: " + actualPayload.keySet());
            System.out.println("🎯 [PPT引擎] 实际传入 Payload: " + actualPayload.toString());
            System.out.println("🚀 [PPT引擎] 启动渲染引擎...");
            PPTUtil.directFillPPT(templatePath, actualPayload, response.getOutputStream());
            System.out.println("✅ [PPT引擎] ========== PPT 渲染诊断结束 ==========");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "❌ PPT 生成引擎崩溃：" + e.getMessage());
        }

        return null;
    }
}