package com.alex.servlet;

import com.alex.service.ForumService;
import com.alex.service.impl.ForumServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/posts")
public class AdminPostServlet extends BaseServlet {

    private ForumService forumService = new ForumServiceImpl();

    protected String index(HttpServletRequest request, HttpServletResponse response) {
        request.setAttribute("allPosts", forumService.selectAllPostsForAdmin());
        return "/admin-posts.jsp";
    }

    protected String delete(HttpServletRequest request, HttpServletResponse response) {
        int id = Integer.parseInt(request.getParameter("id"));

        if (forumService.deletePostById(id)) {
            request.getSession().setAttribute("msg", "✅ 该推文及内含的工作流快照已成功下架！");
        } else {
            request.getSession().setAttribute("msg", "❌ 下架失败，服务器底层异常");
        }
        return "redirect:posts?action=index";
    }
}