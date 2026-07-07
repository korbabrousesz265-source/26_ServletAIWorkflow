package com.alex.servlet;

import com.alex.pojo.User;
import com.alex.service.UserService;
import com.alex.service.impl.UserServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/userServlet")
public class UserServlet extends BaseServlet {

    private UserService userService = new UserServiceImpl();

    protected String index(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pageStr = request.getParameter("currentPage");
        String keyword = request.getParameter("keyword");

        int currentPage = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
        int pageSize = 10;

        // 直接找 Service 拿组装好的分页对象
        request.setAttribute("pageBean", userService.getUsersByPage(keyword, currentPage, pageSize));
        request.setAttribute("keyword", keyword);

        return "user-manage.jsp";
    }

    protected String add(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User u = new User();
        u.setUsername(request.getParameter("username"));
        u.setEmail(request.getParameter("email"));
        u.setPassword(request.getParameter("password"));
        u.setRoleId(Integer.parseInt(request.getParameter("roleId")));

        if (userService.register(u)) {
            request.getSession().setAttribute("msg", "✅ 用户 [" + u.getUsername() + "] 添加成功！");
        } else {
            request.getSession().setAttribute("msg", "❌ 添加失败：用户名或邮箱可能已存在");
        }
        return "redirect:userServlet?action=index";
    }

    protected String block(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        int isBlocked = Integer.parseInt(request.getParameter("isBlocked"));

        if (userService.updateUserStatus(userId, isBlocked)) {
            String statusMsg = (isBlocked == 1) ? "已被屏蔽 🚫" : "已恢复正常 ✅";
            request.getSession().setAttribute("msg", "操作成功：该用户" + statusMsg);
        } else {
            request.getSession().setAttribute("msg", "❌ 操作失败");
        }
        return "redirect:userServlet?action=index";
    }
}