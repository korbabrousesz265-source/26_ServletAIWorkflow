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
}