package com.alex.mapper;

import com.alex.pojo.SysApiKey;
import org.apache.ibatis.annotations.*;

public interface SysApiKeyMapper {
    /**
     * 👑 查询指定用户的 API 密钥
     */
    @Select("SELECT * FROM sys_api_key WHERE user_id = #{userId}")
    SysApiKey getApiKeyByUserId(@Param("userId") int userId);

    /**
     * 👑 保存或更新 API 密钥（一键 Upsert 级联更新）
     */
    @Insert("INSERT INTO sys_api_key (user_id, openai_key, deepseek_key) VALUES (#{userId}, #{openaiKey}, #{deepseekKey}) " +
            "ON DUPLICATE KEY UPDATE openai_key = #{openaiKey}, deepseek_key = #{deepseekKey}")
    int saveOrUpdateApiKey(SysApiKey apiKey);
}