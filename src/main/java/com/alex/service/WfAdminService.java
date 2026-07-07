package com.alex.service;
public interface WfAdminService {
    int getTotalUserCount();
    long getTotalTokensConsumed();
    int getTotalAiCalls();
    Object getRecentCallTrend();
}