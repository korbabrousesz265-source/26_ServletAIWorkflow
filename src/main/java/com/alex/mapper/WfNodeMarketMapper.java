package com.alex.mapper;

import com.alex.pojo.WfNodeMarket;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;
import java.util.List;

public interface WfNodeMarketMapper {

    /**
     * 👑 核心引擎方法：根据 ID 获取节点详细信息（包含 systemPrompt）
     * 供 ChatServlet 在执行工作流时动态提取大模型指令
     */
    @Select("SELECT * FROM wf_node_market WHERE id = #{id}")
    WfNodeMarket getNodeById(@Param("id") int id);

    /**
     * 👑 查询所有节点，并联表获取创建者名字 (author_id = 0 代表系统官方)
     */
    @Select("SELECT n.*, IFNULL(u.username, '系统官方') as author_name " +
            "FROM wf_node_market n " +
            "LEFT JOIN user u ON n.author_id = u.id " +
            "ORDER BY n.id DESC")
    List<WfNodeMarket> getAllNodes();

    /**
     * 👑 核心：用户发布自定义节点
     */
    @Insert("INSERT INTO wf_node_market(name, provider, description, token_cost, icon, system_prompt, author_id, create_time) " +
            "VALUES(#{name}, #{provider}, #{description}, #{tokenCost}, #{icon}, #{systemPrompt}, #{authorId}, NOW())")
    int insertNode(WfNodeMarket node);

    /**
     * 👑 删除节点（仅作者本人可调用）
     */
    @Delete("DELETE FROM wf_node_market WHERE id = #{id}")
    int deleteNodeById(@Param("id") int id);
}