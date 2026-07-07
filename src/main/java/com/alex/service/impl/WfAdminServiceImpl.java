package com.alex.service.impl;

import com.alex.mapper.WfAdminMapper;
import com.alex.service.WfAdminService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;

public class WfAdminServiceImpl implements WfAdminService {
    @Override
    public int getTotalUserCount() {
        try (SqlSession s = MyBatisUtil.getSqlSession()) { return s.getMapper(WfAdminMapper.class).getTotalUserCount(); }
    }
    @Override
    public long getTotalTokensConsumed() {
        try (SqlSession s = MyBatisUtil.getSqlSession()) { return s.getMapper(WfAdminMapper.class).getTotalTokensConsumed(); }
    }
    @Override
    public int getTotalAiCalls() {
        try (SqlSession s = MyBatisUtil.getSqlSession()) { return s.getMapper(WfAdminMapper.class).getTotalAiCalls(); }
    }
    @Override
    public Object getRecentCallTrend() {
        try (SqlSession s = MyBatisUtil.getSqlSession()) { return s.getMapper(WfAdminMapper.class).getRecentCallTrend(); }
    }
}