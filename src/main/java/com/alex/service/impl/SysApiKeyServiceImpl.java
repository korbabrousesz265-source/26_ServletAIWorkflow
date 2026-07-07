package com.alex.service.impl;

import com.alex.mapper.SysApiKeyMapper;
import com.alex.pojo.SysApiKey;
import com.alex.service.SysApiKeyService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;

public class SysApiKeyServiceImpl implements SysApiKeyService {

    @Override
    public SysApiKey getApiKeyByUserId(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(SysApiKeyMapper.class).getApiKeyByUserId(userId);
        }
    }

    @Override
    public boolean saveOrUpdateApiKey(SysApiKey apiKey) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(SysApiKeyMapper.class).saveOrUpdateApiKey(apiKey);
            sqlSession.commit(); // 统一在 Service 提交事务
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}