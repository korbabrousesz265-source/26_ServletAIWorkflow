package com.alex.servlet;

import com.alex.pojo.SysApiKey;
import com.alex.service.ForumService;
import com.alex.service.SysApiKeyService;
import com.alex.service.impl.ForumServiceImpl;
import com.alex.service.impl.SysApiKeyServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends BaseServlet {

    private SysApiKeyService apiKeyService = new SysApiKeyServiceImpl();
    private ForumService forumService = new ForumServiceImpl();

    /**
     * 默认入口：加载个人中心全部数据
     */
    protected String index(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null) return "redirect:login.jsp";

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        // 1. 加载 API Key
        SysApiKey apiKey = apiKeyService.getApiKeyByUserId(userId);
        if (apiKey != null) {
            request.setAttribute("openaiKey", apiKey.getOpenaiKey());
            request.setAttribute("deepseekKey", apiKey.getDeepseekKey());
        }

        // 2. 加载我关注的用户列表
        request.setAttribute("followingList", forumService.getFollowingUsers(userId));

        // 3. 加载我收藏的帖子列表
        request.setAttribute("favoritePostList", forumService.getFavoritePosts(userId));

        return "profile.jsp";
    }

    /**
     * 保存 API Key
     */
    protected String saveApiKey(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null) return "redirect:login.jsp";

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        SysApiKey apiKey = new SysApiKey();
        apiKey.setUserId(userId);
        apiKey.setOpenaiKey(request.getParameter("openai_key"));
        apiKey.setDeepseekKey(request.getParameter("deepseek_key"));

        if (apiKeyService.saveOrUpdateApiKey(apiKey)) {
            session.setAttribute("msg", "✅ API 密钥保存成功！");
        } else {
            session.setAttribute("msg", "❌ 保存失败，服务器发生异常");
        }

        return "redirect:profile?action=index";
    }

    /**
     * 取消关注某个用户
     */
    protected String unfollow(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null) return "redirect:login.jsp";

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        String followedIdStr = request.getParameter("followedId");
        if (followedIdStr != null) {
            int followedId = Integer.parseInt(followedIdStr);
            forumService.unfollow(userId, followedId);
            session.setAttribute("msg", "已取消关注");
        }

        return "redirect:profile?action=index";
    }

    /**
     * 取消收藏帖子
     */
    protected String unfavorite(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session == null) return "redirect:login.jsp";

        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        String postIdStr = request.getParameter("postId");
        if (postIdStr != null) {
            int postId = Integer.parseInt(postIdStr);
            forumService.unfavorite(userId, postId);
            session.setAttribute("msg", "已取消收藏");
        }

        return "redirect:profile?action=index";
    }
}