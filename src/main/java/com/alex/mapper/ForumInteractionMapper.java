package com.alex.mapper;

import com.alex.pojo.ForumComment;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

public interface ForumInteractionMapper {
    // ================= 评论模块 =================
    @Select("SELECT c.*, u.username as user_name FROM forum_comment c JOIN user u ON c.user_id = u.id WHERE c.post_id = #{postId} ORDER BY c.create_time ASC")
    List<ForumComment> getCommentsByPostId(@Param("postId") int postId);

    @Insert("INSERT INTO forum_comment(post_id, user_id, content, create_time) VALUES(#{postId}, #{userId}, #{content}, NOW())")
    int insertComment(ForumComment comment);

    // ================= 收藏/点赞模块 =================
    @Select("SELECT COUNT(*) FROM user_favorite WHERE user_id = #{userId} AND post_id = #{postId}")
    int isFavorited(@Param("userId") int userId, @Param("postId") int postId);

    @Insert("INSERT INTO user_favorite(user_id, post_id, create_time) VALUES(#{userId}, #{postId}, NOW())")
    int addFavorite(@Param("userId") int userId, @Param("postId") int postId);

    @Delete("DELETE FROM user_favorite WHERE user_id = #{userId} AND post_id = #{postId}")
    int removeFavorite(@Param("userId") int userId, @Param("postId") int postId);

    @Select("SELECT COUNT(*) FROM user_favorite WHERE post_id = #{postId}")
    int getFavoriteCount(@Param("postId") int postId);

    // ================= 关注模块 =================
    @Select("SELECT COUNT(*) FROM user_follow WHERE follower_id = #{followerId} AND followed_id = #{followedId}")
    int isFollowed(@Param("followerId") int followerId, @Param("followedId") int followedId);

    @Insert("INSERT INTO user_follow(follower_id, followed_id, create_time) VALUES(#{followerId}, #{followedId}, NOW())")
    int addFollow(@Param("followerId") int followerId, @Param("followedId") int followedId);

    @Delete("DELETE FROM user_follow WHERE follower_id = #{followerId} AND followed_id = #{followedId}")
    int removeFollow(@Param("followerId") int followerId, @Param("followedId") int followedId);

    @Select("SELECT u.id, u.username, uf.create_time as followTime " +
            "FROM user_follow uf JOIN user u ON uf.followed_id = u.id " +
            "WHERE uf.follower_id = #{userId} ORDER BY uf.create_time DESC")
    List<Map<String, Object>> getFollowingUsers(@Param("userId") int userId);

    // ================= 收藏/点赞列表模块 =================
    @Select("SELECT p.id, p.title, p.category, uf.create_time as favTime " +
            "FROM user_favorite uf JOIN forum_post p ON uf.post_id = p.id " +
            "WHERE uf.user_id = #{userId} ORDER BY uf.create_time DESC")
    List<Map<String, Object>> getFavoritePosts(@Param("userId") int userId);
}