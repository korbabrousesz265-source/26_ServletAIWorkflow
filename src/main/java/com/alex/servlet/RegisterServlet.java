package com.alex.servlet;

import com.alex.pojo.User;
import com.alex.service.UserService;
import com.alex.service.impl.UserServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserService userService = new UserServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User newUser = new User();
        newUser.setUsername(request.getParameter("username"));
        newUser.setEmail(request.getParameter("email"));
        newUser.setPassword(request.getParameter("password"));

        // 呼叫 UserService 处理注册和事务！
        if (userService.register(newUser)) {
            request.getSession().setAttribute("msg", "✅ 注册成功！请使用新账号登录。");
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("msg", "❌ 注册失败：该用户名或邮箱可能已被使用，或服务器内部错误！");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}