package com.alex.service;

import com.alex.pojo.ForumPost;
import java.util.List;
import java.util.Map;

// 这是一个接口，定义了论坛相关的业务能力
public interface ForumService {
    // 业务：发布帖子
    boolean publishPost(ForumPost post);

    // 业务：获取帖子列表
    List<ForumPost> getAllPosts(String category);

    // --- 管理员专用方法 ---
    List<Map<String, Object>> selectAllPostsForAdmin();
    boolean deletePostById(int id);
}