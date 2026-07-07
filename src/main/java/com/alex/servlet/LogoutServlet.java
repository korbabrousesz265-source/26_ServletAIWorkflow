package com.alex.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 获取当前 Session，且不创建新的 (false)
        HttpSession session = request.getSession(false);

        // 2. 如果 Session 存在，直接将其彻底销毁
        if (session != null) {
            session.invalidate();
        }
        // 1. 销毁内存 Session
        request.getSession().invalidate();

        // 2. 👑 销毁浏览器里的 Cookie (将存活时间设为 0)
        jakarta.servlet.http.Cookie killCookie = new jakarta.servlet.http.Cookie("auto_login_id", null);
        killCookie.setMaxAge(0); // 0 代表立即删除
        killCookie.setPath("/"); // 必须和写入时的 Path 保持一致！
        response.addCookie(killCookie);


        // 3. 踢回登录页，并带上友好的提示语
        request.setAttribute("msg", "👋 您已安全退出系统，欢迎下次使用！");
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}