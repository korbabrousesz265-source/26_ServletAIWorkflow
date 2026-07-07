package com.alex.mapper;

import com.alex.pojo.ForumPost;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;
import java.util.Map;

public interface ForumPostMapper {

    /**
     * 👑 管理员专享：全量联表检索社区帖子大盘
     * 自动处理下划线（create_time, workflow_snapshot）
     */
    @Select("SELECT p.id, p.title, p.category, p.create_time as createTime, u.username as authorName, " +
            "LENGTH(p.workflow_snapshot) as snapshotLength " +
            "FROM forum_post p " +
            "JOIN user u ON p.author_id = u.id " +
            "ORDER BY p.create_time DESC")
    List<Map<String, Object>> selectAllPostsForAdmin();

    /**
     * 👑 强力下架：根据 ID 物理删除帖子，触发底层级联删除评论与收藏
     */
    @Delete("DELETE FROM forum_post WHERE id = #{id}")
    int deletePostById(@Param("id") int id);

    // 列表显示：关联查询作者名
    @Select("<script>" +
            "SELECT p.*, u.username as author_name " +
            "FROM forum_post p JOIN user u ON p.author_id = u.id " +
            "<where>" +
            "    <if test='category != null and category != \"\"'>" +
            "        p.category = #{category} " +
            "    </if>" +
            "</where> " +
            "ORDER BY p.create_time DESC" +
            "</script>")
    List<ForumPost> getAllPosts(@Param("category") String category);

    // 详情显示
    @Select("SELECT p.*, u.username as author_name FROM forum_post p JOIN user u ON p.author_id = u.id WHERE p.id = #{id}")
    ForumPost getPostById(@Param("id") int id);

    // 发布帖子
    @Insert("INSERT INTO forum_post(title, category, content, workflow_snapshot, author_id, create_time) " +
            "VALUES(#{title}, #{category}, #{content}, #{workflowSnapshot}, #{authorId}, NOW())")
    int insertPost(ForumPost post);

}