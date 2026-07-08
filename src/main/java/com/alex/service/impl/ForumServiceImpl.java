package com.alex.service.impl;

import com.alex.mapper.ForumPostMapper;
import com.alex.mapper.ForumInteractionMapper;
import com.alex.pojo.ForumPost;
import com.alex.service.ForumService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import java.util.List;
import java.util.Map;

public class ForumServiceImpl implements ForumService {

    @Override
    public boolean publishPost(ForumPost post) {
        // 主厨开始做菜：获取数据库连接
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper mapper = sqlSession.getMapper(ForumPostMapper.class);

            // 🔥 这里可以写纯业务逻辑！
            // 比如：检查帖子里有没有违禁词、给用户增加积分等等

            int rows = mapper.insertPost(post);
            sqlSession.commit(); // 统一在 Service 层提交事务！
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false; // 如果报错，告诉 Servlet 做菜失败了
        }
    }

    @Override
    public List<ForumPost> getAllPosts(String category) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            ForumPostMapper mapper = sqlSession.getMapper(ForumPostMapper.class);
            // 👑 核心修复：把参数传给 Mapper
            return mapper.getAllPosts(category);
        }
    }
    @Override
    public List<Map<String, Object>> selectAllPostsForAdmin() {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(ForumPostMapper.class).selectAllPostsForAdmin();
        }
    }

    @Override
    public boolean deletePostById(int id) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(ForumPostMapper.class).deletePostById(id);
            sqlSession.commit();
            return rows > 0;
        }
    }

    @Override
    public List<Map<String, Object>> getFollowingUsers(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(ForumInteractionMapper.class).getFollowingUsers(userId);
        }
    }

    @Override
    public List<Map<String, Object>> getFavoritePosts(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(ForumInteractionMapper.class).getFavoritePosts(userId);
        }
    }

    @Override
    public boolean unfollow(int followerId, int followedId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(ForumInteractionMapper.class).removeFollow(followerId, followedId);
            sqlSession.commit();
            return rows > 0;
        }
    }

    @Override
    public boolean unfavorite(int userId, int postId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(ForumInteractionMapper.class).removeFavorite(userId, postId);
            sqlSession.commit();
            return rows > 0;
        }
    }
}