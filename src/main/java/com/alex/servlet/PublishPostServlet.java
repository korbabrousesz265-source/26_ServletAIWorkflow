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

    /**
     * 👑 发布工作流模板帖子
     * 处理 publish-post.jsp 表单提交，将帖子数据写入数据库
     */
    protected String add(HttpServletRequest request, HttpServletResponse response) {
        // 🔒 登录检查：未登录用户不允许发布帖子
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            request.getSession().setAttribute("msg", "请先登录后再发布帖子");
            return "redirect:login.jsp";
        }

        // 1. 接收表单参数
        String title = request.getParameter("title");
        String category = request.getParameter("categoryId"); // 表单字段名为 categoryId，实际存分类名
        String content = request.getParameter("content");
        String workflowSnapshot = request.getParameter("workflowSnapshot");

        // 2. 基础校验：标题和内容不能为空
        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("msg", "标题不能为空");
            return "/publish-post.jsp";
        }
        if (content == null || content.trim().isEmpty()) {
            request.setAttribute("msg", "内容不能为空");
            return "/publish-post.jsp";
        }

        // 3. 封装 ForumPost 对象
        ForumPost post = new ForumPost();
        post.setTitle(title.trim());
        post.setCategory(category != null ? category.trim() : "未分类");
        post.setContent(content.trim());
        post.setWorkflowSnapshot(workflowSnapshot != null ? workflowSnapshot.trim() : "{}");
        post.setAuthorId(userId);

        // 4. 调用 Service 层写入数据库
        boolean success = forumService.publishPost(post);

        // 5. 根据结果跳转
        if (success) {
            request.getSession().setAttribute("msg", "✅ 帖子发布成功！");
            return "redirect:forum?action=index";
        } else {
            request.setAttribute("msg", "❌ 发布失败，请稍后重试");
            return "/publish-post.jsp";
        }
    }
}