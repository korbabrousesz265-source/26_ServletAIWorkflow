package com.alex.service.impl;

import com.alex.mapper.MessageMapper;
import com.alex.pojo.Message;
import com.alex.service.MessageService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import java.util.List;

public class MessageServiceImpl implements MessageService {

    @Override
    public List<Message> getMessagesByUserId(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(MessageMapper.class).getMessagesByUserId(userId);
        }
    }

    @Override
    public List<Message> getMessagesByUserIdAndType(int userId, String type) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(MessageMapper.class).getMessagesByUserIdAndType(userId, type);
        }
    }

    @Override
    public boolean createMessage(Message message) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(MessageMapper.class).insertMessage(message);
            sqlSession.commit();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public int getUnreadCount(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(MessageMapper.class).getUnreadCount(userId);
        }
    }

    @Override
    public boolean markAllAsRead(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(MessageMapper.class).markAllAsRead(userId);
            sqlSession.commit(); // 🚨 更新操作必须提交事务！
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}