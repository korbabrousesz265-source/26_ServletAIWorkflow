package com.alex.servlet;

import com.alex.pojo.User;
import com.alex.service.UserService;
import com.alex.service.impl.UserServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    // 👑 雇佣一位用户业务主厨
    private UserService userService = new UserServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 👑 呼叫主厨进行校验，Servlet 再也不用管 MyBatis 的死活了！
        User user = userService.login(username, password);

        if (user != null) {
            if (user.getIsBlocked() == 1) {
                request.setAttribute("msg", "🚫 您的账号已被封禁，请联系管理员！");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("userId", user.getId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("roleId", user.getRoleId());

            // 👑 恢复免死金牌：如果勾选了"记住我"，签发 7 天免登录 Cookie
            String rememberMe = request.getParameter("rememberMe");
            if ("on".equals(rememberMe)) {
                jakarta.servlet.http.Cookie loginCookie = new jakarta.servlet.http.Cookie("auto_login_id", String.valueOf(user.getId()));
                loginCookie.setMaxAge(60 * 60 * 24 * 7); // 有效期 7 天
                loginCookie.setPath("/"); // 允许全站访问
                response.addCookie(loginCookie);
            }

            response.sendRedirect("chat");
        } else {
            request.setAttribute("msg", "❌ 用户名或密码错误，请重试");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}