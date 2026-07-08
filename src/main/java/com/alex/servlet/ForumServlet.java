package com.alex.servlet;

import com.alex.mapper.ForumPostMapper;
import com.alex.mapper.ForumInteractionMapper;
import com.alex.mapper.UserMapper;
import com.alex.pojo.ForumPost;
import com.alex.pojo.ForumComment;
import com.alex.pojo.Message;
import com.alex.pojo.User;
import com.alex.service.ForumService;
import com.alex.service.MessageService;
import com.alex.service.impl.ForumServiceImpl;
import com.alex.service.impl.MessageServiceImpl;
import com.alex.utils.MyBatisUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

@WebServlet("/forum")
public class ForumServlet extends BaseServlet {

    private MessageService messageService = new MessageServiceImpl();

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

    // 3. 切换收藏状态（点赞/取消点赞）
    protected String toggleFavorite(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String postIdStr = request.getParameter("postId");
        if (userId == null) return "redirect:login.jsp";

        int postId = Integer.parseInt(postIdStr);
        boolean isAdding = false; // 标记本次是点赞还是取消

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumInteractionMapper mapper = sqlSession.getMapper(ForumInteractionMapper.class);
            if (mapper.isFavorited(userId, postId) > 0) {
                mapper.removeFavorite(userId, postId);
            } else {
                mapper.addFavorite(userId, postId);
                isAdding = true;
            }
            sqlSession.commit();
        }

        // 🔔 点赞通知：仅在执行点赞操作时发送（取消点赞不发）
        if (isAdding) {
            sendLikeNotification(userId, postId);
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
        String content = request.getParameter("commentContent");
        int postId = Integer.parseInt(postIdStr);

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumInteractionMapper mapper = sqlSession.getMapper(ForumInteractionMapper.class);
            ForumComment comment = new ForumComment();
            comment.setPostId(postId);
            comment.setUserId(userId);
            comment.setContent(content);
            mapper.insertComment(comment);
            sqlSession.commit();
        }

        // 🔔 评论通知：给帖子作者发送通知
        sendCommentNotification(userId, postId, content);

        return "redirect:forum?action=detail&id=" + postIdStr;
    }

    // 6. 👑 删除自己的帖子
    protected String deletePost(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        String postIdStr = request.getParameter("id");
        if (postIdStr == null) return "redirect:forum?action=index";

        int postId = Integer.parseInt(postIdStr);

        // 🔒 验证所有权
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper postMapper = sqlSession.getMapper(ForumPostMapper.class);
            ForumPost post = postMapper.getPostById(postId);
            if (post != null && post.getAuthorId() == userId) {
                sqlSession.getMapper(ForumPostMapper.class).deletePostById(postId);
                sqlSession.commit();
                request.getSession().setAttribute("msg", "✅ 帖子已成功删除");
            } else {
                request.getSession().setAttribute("msg", "❌ 无权删除该帖子");
            }
        }

        return "redirect:forum?action=index";
    }

    // ==================== 🔔 通知辅助方法 ====================

    /**
     * 发送点赞通知给帖子作者
     */
    private void sendLikeNotification(int likerUserId, int postId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper postMapper = sqlSession.getMapper(ForumPostMapper.class);
            UserMapper userMapper = sqlSession.getMapper(UserMapper.class);

            ForumPost post = postMapper.getPostById(postId);
            if (post == null) return;

            // 不给自己发通知
            if (post.getAuthorId() == likerUserId) return;

            User liker = userMapper.getUserById(likerUserId);
            if (liker == null) return;

            // 截取帖子标题（避免过长）
            String postTitle = post.getTitle();
            if (postTitle.length() > 20) {
                postTitle = postTitle.substring(0, 20) + "...";
            }

            Message msg = new Message();
            msg.setUserId(post.getAuthorId());
            msg.setType("like");
            msg.setIcon("thumb-up");
            msg.setTitle("新点赞提醒");
            msg.setContent("用户 " + liker.getUsername() + " 点赞了你的帖子《" + postTitle + "》");
            msg.setLink("forum?action=detail&id=" + postId);

            messageService.createMessage(msg);
        } catch (Exception e) {
            e.printStackTrace(); // 通知发送失败不影响主流程
        }
    }

    /**
     * 发送评论通知给帖子作者
     */
    private void sendCommentNotification(int commenterUserId, int postId, String commentContent) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper postMapper = sqlSession.getMapper(ForumPostMapper.class);
            UserMapper userMapper = sqlSession.getMapper(UserMapper.class);

            ForumPost post = postMapper.getPostById(postId);
            if (post == null) return;

            // 不给自己发通知
            if (post.getAuthorId() == commenterUserId) return;

            User commenter = userMapper.getUserById(commenterUserId);
            if (commenter == null) return;

            // 截取评论和标题
            String postTitle = post.getTitle();
            if (postTitle.length() > 20) {
                postTitle = postTitle.substring(0, 20) + "...";
            }
            String snippet = commentContent;
            if (snippet != null && snippet.length() > 30) {
                snippet = snippet.substring(0, 30) + "...";
            }

            Message msg = new Message();
            msg.setUserId(post.getAuthorId());
            msg.setType("comment");
            msg.setIcon("message-2");
            msg.setTitle("新评论提醒");
            msg.setContent("用户 " + commenter.getUsername() + " 在你的帖子《" + postTitle + "》下留言：" + snippet);
            msg.setLink("forum?action=detail&id=" + postId);

            messageService.createMessage(msg);
        } catch (Exception e) {
            e.printStackTrace(); // 通知发送失败不影响主流程
        }
    }
}