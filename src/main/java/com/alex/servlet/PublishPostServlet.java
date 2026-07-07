package com.alex.servlet;

import com.alex.pojo.ForumPost;
import com.alex.service.ForumService;
import com.alex.service.impl.ForumServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


@WebServlet("/publish")
public class PublishPostServlet extends BaseServlet {

    // 雇佣一个主厨 (后续学了 Spring 会变成自动注入 @Autowired)
    private ForumService forumService = new ForumServiceImpl();

    protected String add(HttpServletRequest request, HttpServletResponse response) {
        // 1. 服务员接待：接收参数并封装
        ForumPost post = new ForumPost();
        post.setTitle(request.getParameter("title"));
        post.setContent(request.getParameter("content"));
        // ... 封装其他参数

        // 2. 喊主厨做菜！Servlet 根本不知道底层连的是不是 MySQL，它不关心！
        boolean success = forumService.publishPost(post);

        // 3. 服务员上菜：根据结果跳转页面
        if (success) {
            return "redirect:forum?action=index";
        } else {
            request.setAttribute("msg", "发布失败啦");
            return "/publish-post.jsp";
        }
    }
}