package com.alex.service;

import com.alex.pojo.WfHistoryLog;
import java.util.List;

public interface WfHistoryLogService {
    List<WfHistoryLog> selectAllLogs();
    List<WfHistoryLog> getLogsByUserId(int userId);
    boolean insertLog(WfHistoryLog log);

    // 大盘统计聚合方法
    int getTotalApiCalls();
    int getTotalTokens();
    int getAvgDuration();
}