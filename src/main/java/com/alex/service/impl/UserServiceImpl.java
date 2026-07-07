package com.alex.service.impl;

import com.alex.mapper.UserMapper;
import com.alex.pojo.PageBean;
import com.alex.pojo.User;
import com.alex.service.UserService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import java.util.List;

public class UserServiceImpl implements UserService {

    @Override
    public User login(String username, String password) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            UserMapper mapper = sqlSession.getMapper(UserMapper.class);
            return mapper.login(username, password);
        }
    }

    @Override
    public boolean register(User user) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            UserMapper mapper = sqlSession.getMapper(UserMapper.class);
            int rows = mapper.insertUser(user);
            sqlSession.commit(); // 👑 事务提交统一放在 Service 层！
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false; // 如果用户名重复等报错，直接返回 false
        }
    }

    @Override
    public User getUserById(int id) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(UserMapper.class).getUserById(id);
        }
    }

    @Override
    public PageBean<User> getUsersByPage(String keyword, int currentPage, int pageSize) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            UserMapper mapper = sqlSession.getMapper(UserMapper.class);
            int totalCount = mapper.countUsers(keyword);
            int offset = (currentPage - 1) * pageSize;
            List<User> userList = mapper.getUsers(keyword, offset, pageSize);
            return new PageBean<>(currentPage, pageSize, totalCount, userList);
        }
    }

    @Override
    public boolean updateUserStatus(int userId, int isBlocked) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(UserMapper.class).updateUserStatus(userId, isBlocked);
            sqlSession.commit();
            return rows > 0;
        }
    }
}