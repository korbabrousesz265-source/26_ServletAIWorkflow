package com.alex.service;

import com.alex.pojo.User;
import com.alex.pojo.PageBean;

public interface UserService {
    // 登录业务
    User login(String username, String password);
    // 注册业务
    boolean register(User user);
    // 根据ID获取用户 (用于免密登录验证)
    User getUserById(int id);
    // 分页+关键字获取用户列表 (后台管理)
    PageBean<User> getUsersByPage(String keyword, int currentPage, int pageSize);
    // 封禁/解封用户
    boolean updateUserStatus(int userId, int isBlocked);
}