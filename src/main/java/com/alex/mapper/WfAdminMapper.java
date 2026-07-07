package com.alex.mapper;

import com.alex.pojo.WfHistoryLog;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;
import java.util.Map;

public interface WfAdminMapper {

    /** 1. 核心指标统计 */
    @Select("SELECT COUNT(*) FROM user")
    int getTotalUserCount();

    @Select("SELECT IFNULL(SUM(token_used), 0) FROM wf_history_log")
    long getTotalTokensConsumed();

    @Select("SELECT COUNT(*) FROM wf_history_log")
    int getTotalAiCalls();

    /** 2. 统计各节点的消耗分布 (用于饼图) */
    @Select("SELECT node_name as name, SUM(token_used) as value FROM wf_history_log GROUP BY node_name")
    List<Map<String, Object>> getTokenDistributionByNode();

    /** 3. 最近 7 天调用趋势 (用于折线图) */
    @Select("SELECT DATE_FORMAT(create_time, '%m-%d') as date, COUNT(*) as count " +
            "FROM wf_history_log " +
            "WHERE create_time > DATE_SUB(NOW(), INTERVAL 7 DAY) " +
            "GROUP BY date ORDER BY date ASC")
    List<Map<String, Object>> getRecentCallTrend();

    /**
     * 👑 管理员大盘：查询全站所有执行日志
     */
    @Select("SELECT * FROM wf_history_log ORDER BY create_time DESC LIMIT 100")
    List<WfHistoryLog> selectAllLogs();

    /**
     * 👑 个人中心：查询当前登录用户的执行日志
     */
    @Select("SELECT * FROM wf_history_log WHERE user_id = #{userId} ORDER BY create_time DESC")
    List<WfHistoryLog> getLogsByUserId(@Param("userId") int userId);

    /**
     * 👑 计费引擎：插入一条新的执行轨迹日志
     */
    @Insert("INSERT INTO wf_history_log(user_id, workflow_name, node_name, token_used, duration, create_time) " +
            "VALUES(#{userId}, #{workflowName}, #{nodeName}, #{tokenUsed}, #{duration}, NOW())")
    int insertLog(WfHistoryLog log);
}