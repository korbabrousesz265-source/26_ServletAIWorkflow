package com.alex.service.impl;

import com.alex.mapper.SysApiKeyMapper;
import com.alex.pojo.SysApiKey;
import com.alex.service.SysApiKeyService;
import com.alex.utils.AESUtil;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;

public class SysApiKeyServiceImpl implements SysApiKeyService {

    @Override
    public SysApiKey getApiKeyByUserId(int userId) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            // 1. 从数据库读取 (此时是密文)[cite: 16]
            SysApiKey apiKey = sqlSession.getMapper(SysApiKeyMapper.class).getApiKeyByUserId(userId);

            // 2. 👑 内存解密拦截：将密文还原为明文，再返回给上一层 Servlet
            if (apiKey != null) {
                apiKey.setOpenaiKey(AESUtil.decrypt(apiKey.getOpenaiKey()));
                apiKey.setDeepseekKey(AESUtil.decrypt(apiKey.getDeepseekKey()));
            }
            return apiKey;
        }
    }

    @Override
    public boolean saveOrUpdateApiKey(SysApiKey apiKey) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {

            // 1. 👑 落盘加密拦截：将前端传来的明文在内存中变更为密文
            apiKey.setOpenaiKey(AESUtil.encrypt(apiKey.getOpenaiKey()));
            apiKey.setDeepseekKey(AESUtil.encrypt(apiKey.getDeepseekKey()));

            // 2. 执行持久化写入 (数据库里存的就是加密后的乱码了)[cite: 16]
            int rows = sqlSession.getMapper(SysApiKeyMapper.class).saveOrUpdateApiKey(apiKey);
            sqlSession.commit(); // 统一在 Service 提交事务[cite: 16]
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}