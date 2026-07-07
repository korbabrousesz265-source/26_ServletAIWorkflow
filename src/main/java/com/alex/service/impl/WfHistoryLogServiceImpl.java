package com.alex.service.impl;

import com.alex.mapper.WfHistoryLogMapper;
import com.alex.pojo.WfHistoryLog;
import com.alex.service.WfHistoryLogService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import java.util.List;

public class WfHistoryLogServiceImpl implements WfHistoryLogService {

    @Override
    public List<WfHistoryLog> selectAllLogs() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) { return session.getMapper(WfHistoryLogMapper.class).selectAllLogs(); }
    }

    @Override
    public List<WfHistoryLog> getLogsByUserId(int userId) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) { return session.getMapper(WfHistoryLogMapper.class).getLogsByUserId(userId); }
    }

    @Override
    public boolean insertLog(WfHistoryLog log) {
        try (SqlSession session = MyBatisUtil.getSqlSession()) {
            int rows = session.getMapper(WfHistoryLogMapper.class).insertLog(log);
            session.commit();
            return rows > 0;
        }
    }

    @Override
    public int getTotalApiCalls() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) { return session.getMapper(WfHistoryLogMapper.class).getTotalApiCalls(); }
    }

    @Override
    public int getTotalTokens() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) { return session.getMapper(WfHistoryLogMapper.class).getTotalTokens(); }
    }

    @Override
    public int getAvgDuration() {
        try (SqlSession session = MyBatisUtil.getSqlSession()) { return session.getMapper(WfHistoryLogMapper.class).getAvgDuration(); }
    }
}