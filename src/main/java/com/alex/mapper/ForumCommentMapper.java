package com.alex.mapper;

import com.alex.pojo.ForumComment;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;
import java.util.List;

public interface ForumCommentMapper {
    /**
     * 👑 获取某篇帖子的所有评论（联表查询评论者用户名，按时间正序排列）
     */
    @Select("SELECT c.*, u.username as user_name " +
            "FROM forum_comment c " +
            "JOIN user u ON c.user_id = u.id " +
            "WHERE c.post_id = #{postId} " +
            "ORDER BY c.create_time ASC")
    List<ForumComment> getCommentsByPostId(int postId);

    /**
     * 👑 插入新评论
     */
    @Insert("INSERT INTO forum_comment(post_id, user_id, content) " +
            "VALUES(#{postId}, #{userId}, #{content})")
    int insertComment(ForumComment comment);
}