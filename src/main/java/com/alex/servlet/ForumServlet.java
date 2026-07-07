package com.alex.servlet;

import com.alex.mapper.ForumPostMapper;
import com.alex.mapper.ForumInteractionMapper;
import com.alex.pojo.ForumPost;
import com.alex.pojo.ForumComment;
import com.alex.service.ForumService;
import com.alex.service.impl.ForumServiceImpl;
import com.alex.utils.MyBatisUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

@WebServlet("/forum")
public class ForumServlet extends BaseServlet {

    // 1. 论坛列表
    // 1. 论坛大厅列表 (支持分类过滤)
    // 1. 论坛大厅列表 (支持分类过滤)
    protected String index(HttpServletRequest request, HttpServletResponse response) {
        // 1. 接收参数
        String category = request.getParameter("category");

        // 2. 实例化 Service (未来用 Spring 可以省去这一步)
        ForumService forumService = new ForumServiceImpl();

        // 3. 👑 核心修复：调用 Service 层并传入 category
        request.setAttribute("postList", forumService.getAllPosts(category));
        request.setAttribute("currentCategory", category);

        return "/forum.jsp";
    }

    // 2. 帖子详情 (包含评论、点赞状态、关注状态)
    protected String detail(HttpServletRequest request, HttpServletResponse response) {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) return "redirect:forum?action=index";
        int postId = Integer.parseInt(idStr);

        Integer userId = (Integer) request.getSession().getAttribute("userId");

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper postMapper = sqlSession.getMapper(ForumPostMapper.class);
            ForumInteractionMapper interactMapper = sqlSession.getMapper(ForumInteractionMapper.class);

            ForumPost post = postMapper.getPostById(postId);
            request.setAttribute("post", post);
            request.setAttribute("commentList", interactMapper.getCommentsByPostId(postId));
            request.setAttribute("favoriteCount", interactMapper.getFavoriteCount(postId));

            // 如果用户已登录，查询他是否点过赞、是否关注了作者
            if (userId != null && post != null) {
                request.setAttribute("isFavorited", interactMapper.isFavorited(userId, postId) > 0);
                request.setAttribute("isFollowed", interactMapper.isFollowed(userId, post.getAuthorId()) > 0);
            } else {
                request.setAttribute("isFavorited", false);
                request.setAttribute("isFollowed", false);
            }
        }
        return "/post-detail.jsp";
    }

    // 3. 切换收藏状态
    protected String toggleFavorite(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String postIdStr = request.getParameter("postId");
        if (userId == null) return "redirect:login.jsp";

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumInteractionMapper mapper = sqlSession.getMapper(ForumInteractionMapper.class);
            int postId = Integer.parseInt(postIdStr);
            if (mapper.isFavorited(userId, postId) > 0) {
                mapper.removeFavorite(userId, postId);
            } else {
                mapper.addFavorite(userId, postId);
            }
            sqlSession.commit();
        }
        return "redirect:forum?action=detail&id=" + postIdStr;
    }

    // 4. 切换关注状态
    protected String toggleFollow(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String authorIdStr = request.getParameter("authorId");
        String postIdStr = request.getParameter("postId"); // 用于操作后跳回原帖子
        if (userId == null) return "redirect:login.jsp";

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumInteractionMapper mapper = sqlSession.getMapper(ForumInteractionMapper.class);
            int authorId = Integer.parseInt(authorIdStr);
            if (userId != authorId) { // 防止自我关注
                if (mapper.isFollowed(userId, authorId) > 0) mapper.removeFollow(userId, authorId);
                else mapper.addFollow(userId, authorId);
                sqlSession.commit();
            }
        }
        return "redirect:forum?action=detail&id=" + postIdStr;
    }

    // 5. 发表评论
    protected String addComment(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        String postIdStr = request.getParameter("postId");
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumInteractionMapper mapper = sqlSession.getMapper(ForumInteractionMapper.class);
            ForumComment comment = new ForumComment();
            comment.setPostId(Integer.parseInt(postIdStr));
            comment.setUserId(userId);
            comment.setContent(request.getParameter("commentContent"));
            mapper.insertComment(comment);
            sqlSession.commit();
        }
        return "redirect:forum?action=detail&id=" + postIdStr;
    }
}