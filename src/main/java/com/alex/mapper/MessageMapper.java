package com.alex.mapper;

import com.alex.pojo.Message;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import java.util.List;

public interface MessageMapper {
    /**
     * 👑 根据用户 ID 查询所有系统消息（按时间倒序）
     */
    @Select("SELECT * FROM sys_message WHERE user_id = #{userId} ORDER BY create_time DESC")
    List<Message> getMessagesByUserId(@Param("userId") int userId);

    /**
     * 👑 根据用户 ID 和消息类型筛选消息（按时间倒序）
     */
    @Select("<script>" +
            "SELECT * FROM sys_message WHERE user_id = #{userId} " +
            "<if test='type != null and type != \"\"'>" +
            "AND type = #{type} " +
            "</if>" +
            "ORDER BY create_time DESC" +
            "</script>")
    List<Message> getMessagesByUserIdAndType(@Param("userId") int userId, @Param("type") String type);

    /**
     * 👑 插入一条新消息通知
     */
    @Insert("INSERT INTO sys_message(user_id, type, icon, title, content, link, create_time, is_read) " +
            "VALUES(#{userId}, #{type}, #{icon}, #{title}, #{content}, #{link}, NOW(), 0)")
    int insertMessage(Message message);

    /**
     * 👑 查询用户未读消息数量（用于顶部导航角标）
     */
    @Select("SELECT COUNT(*) FROM sys_message WHERE user_id = #{userId} AND is_read = 0")
    int getUnreadCount(@Param("userId") int userId);

    /**
     * 👑 一键已读：将该用户的所有消息标记为已读
     */
    @Update("UPDATE sys_message SET is_read = 1 WHERE user_id = #{userId} AND is_read = 0")
    int markAllAsRead(@Param("userId") int userId);
}