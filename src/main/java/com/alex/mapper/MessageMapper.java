package com.alex.mapper;

import com.alex.pojo.Message;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

public interface MessageMapper {
    /**
     * 👑 根据用户 ID 查询所有系统消息（按时间倒序）
     */
    @Select("SELECT * FROM sys_message WHERE user_id = #{userId} ORDER BY create_time DESC")
    List<Message> getMessagesByUserId(@Param("userId") int userId);
}