package com.alex.servlet;

import com.alex.pojo.SysApiKey;
import com.alex.service.SysApiKeyService;
import com.alex.service.impl.SysApiKeyServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private SysApiKeyService apiKeyService = new SysApiKeyServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession(false).getAttribute("userId");

        SysApiKey apiKey = apiKeyService.getApiKeyByUserId(userId);
        if (apiKey != null) {
            request.setAttribute("openaiKey", apiKey.getOpenaiKey());
            request.setAttribute("deepseekKey", apiKey.getDeepseekKey());
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("userId");

        SysApiKey apiKey = new SysApiKey();
        apiKey.setUserId(userId);
        apiKey.setOpenaiKey(request.getParameter("openai_key"));
        apiKey.setDeepseekKey(request.getParameter("deepseek_key"));

        if (apiKeyService.saveOrUpdateApiKey(apiKey)) {
            session.setAttribute("msg", "✅ API 密钥保存成功！");
        } else {
            session.setAttribute("msg", "❌ 保存失败，服务器发生异常");
        }

        response.sendRedirect("profile");
    }
}