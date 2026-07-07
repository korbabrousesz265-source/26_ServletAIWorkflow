package com.alex.mapper;

import com.alex.pojo.User;
import org.apache.ibatis.annotations.*;
import java.util.List;

public interface UserMapper {

    @Select("<script>" +
            "SELECT COUNT(*) FROM user " +
            "<where>" +
            "  <if test='keyword != null and keyword != \"\"'>" +
            "    username LIKE CONCAT('%', #{keyword}, '%') OR email LIKE CONCAT('%', #{keyword}, '%') " +
            "  </if>" +
            "</where>" +
            "</script>")
    int countUsers(@Param("keyword") String keyword);

    /**
     * 👑 核心修复：直接使用 SELECT *，让 MyBatis 自己去把底层的 is_blocked 映射到 isBlocked！
     */
    @Select("<script>" +
            "SELECT * FROM user " +
            "<where>" +
            "  <if test='keyword != null and keyword != \"\"'>" +
            "    username LIKE CONCAT('%', #{keyword}, '%') OR email LIKE CONCAT('%', #{keyword}, '%') " +
            "  </if>" +
            "</where>" +
            "ORDER BY id DESC LIMIT #{offset}, #{limit}" +
            "</script>")
    List<User> getUsers(@Param("keyword") String keyword, @Param("offset") int offset, @Param("limit") int limit);

    /**
     * 👑 核心修复：INSERT 语句里的字段名必须是数据库里真实的下划线命名！
     */
    @Insert("INSERT INTO user(username, email, password, role_id) " +
            "VALUES(#{username}, #{email}, #{password}, #{roleId})")
    int insertUser(User user);

    /**
     * 👑 核心修复：UPDATE 语句同样必须使用 is_blocked
     */
    @Update("UPDATE user SET is_blocked = #{isBlocked} WHERE id = #{userId}")
    int updateUserStatus(@Param("userId") int userId, @Param("isBlocked") int isBlocked);

    @Select("SELECT * FROM user WHERE username = #{username} AND password = #{password}")
    User login(@Param("username") String username, @Param("password") String password);

    @Insert("INSERT INTO user(username, email, password) VALUES(#{username}, #{email}, #{password})")
    int registerUser(User user);
    /**
     * 👑 根据用户 ID 查询单条用户信息 (用于 Cookie 自动登录时的状态恢复)
     */
    @Select("SELECT * FROM user WHERE id = #{id}")
    User getUserById(@Param("id") int id);
}