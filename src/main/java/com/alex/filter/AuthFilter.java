package com.alex.filter;

import com.alex.pojo.User;
import com.alex.service.UserService;
import com.alex.service.impl.UserServiceImpl;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// 拦截所有需要保护的路由
@WebFilter(urlPatterns = {"/chat", "/forum", "/node-market", "/profile", "/history", "/admin/*"})
public class AuthFilter implements Filter {

    // 👑 雇佣主厨，彻底干掉 MyBatis 导包！
    private UserService userService = new UserServiceImpl();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // 1. 如果内存里还有 Session，直接放行
        if (session != null && session.getAttribute("userId") != null) {
            chain.doFilter(request, response);
            return;
        }

        // 2. 尝试从浏览器的 Cookie 里搜刮“免死金牌”
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("auto_login_id".equals(c.getName())) {
                    String userIdStr = c.getValue();

                    // 3. 👑 呼叫 Service 层恢复用户信息！代码极其简短！
                    User user = userService.getUserById(Integer.parseInt(userIdStr));

                    if (user != null && user.getIsBlocked() == 0) {
                        HttpSession newSession = req.getSession(true);
                        newSession.setAttribute("userId", user.getId());
                        newSession.setAttribute("username", user.getUsername());
                        newSession.setAttribute("email", user.getEmail());
                        newSession.setAttribute("roleId", user.getRoleId());

                        chain.doFilter(request, response);
                        return;
                    }
                }
            }
        }

        // 4. 连 Cookie 都没有，踢回登录页
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}