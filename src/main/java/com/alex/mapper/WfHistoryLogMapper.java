package com.alex.mapper;

import com.alex.pojo.WfHistoryLog;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

public interface WfHistoryLogMapper {

    /**
     * 👑 管理员大盘：查询全站所有执行日志 (按时间倒序，限制 100 条防止把内存撑爆)
     * MyBatis 的 mapUnderscoreToCamelCase 会自动把 user_id 转成 userId
     */
    @Select("SELECT * FROM wf_history_log ORDER BY create_time DESC LIMIT 100")
    List<WfHistoryLog> selectAllLogs();

    /**
     * 👑 个人中心：查询当前登录用户的专属执行日志
     */
    @Select("SELECT * FROM wf_history_log WHERE user_id = #{userId} ORDER BY create_time DESC")
    List<WfHistoryLog> getLogsByUserId(@Param("userId") int userId);

    /**
     * 👑 计费引擎：插入一条新的执行轨迹日志
     */
    @Insert("INSERT INTO wf_history_log(user_id, workflow_name, node_name, token_used, duration, create_time) " +
            "VALUES(#{userId}, #{workflowName}, #{nodeName}, #{tokenUsed}, #{duration}, NOW())")
    int insertLog(WfHistoryLog log);
    /**
     * 👑 大盘统计：获取总 API 调用次数
     */
    @Select("SELECT COUNT(*) FROM wf_history_log")
    int getTotalApiCalls();

    /**
     * 👑 大盘统计：获取全站 Token 累计消耗
     */
    @Select("SELECT IFNULL(SUM(token_used), 0) FROM wf_history_log")
    int getTotalTokens();

    /**
     * 👑 大盘统计：获取全站 API 平均响应延迟 (毫秒)
     */
    @Select("SELECT IFNULL(AVG(duration), 0) FROM wf_history_log WHERE duration > 0")
    int getAvgDuration();
}