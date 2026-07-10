package com.alex.mapper;

import com.alex.pojo.WfNodeMarket;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Update;
import java.util.List;

public interface WfNodeMarketMapper {

    /**
     * 👑 核心引擎方法：根据 ID 获取节点详细信息（包含 systemPrompt）
     * 供 ChatServlet 在执行工作流时动态提取大模型指令
     */
    @Select("SELECT * FROM wf_node_market WHERE id = #{id}")
    WfNodeMarket getNodeById(@Param("id") int id);

    /**
     * 👑 前端节点市场：仅展示已审核通过(status=1) 或 系统官方节点(author_id=0)
     */
    @Select("SELECT n.*, IFNULL(u.username, '系统官方') as author_name " +
            "FROM wf_node_market n " +
            "LEFT JOIN user u ON n.author_id = u.id " +
            "WHERE n.status = 1 OR n.author_id = 0 " +
            "ORDER BY n.id DESC")
    List<WfNodeMarket> getAllNodes();

    /**
     * 👑 后台管理：查询所有节点（含待审核、已驳回），用于管理员审核
     */
    @Select("SELECT n.*, IFNULL(u.username, '系统官方') as author_name " +
            "FROM wf_node_market n " +
            "LEFT JOIN user u ON n.author_id = u.id " +
            "ORDER BY n.id DESC")
    List<WfNodeMarket> getAllNodesForAdmin();

    /**
     * 👑 后台管理：按状态筛选节点
     */
    @Select("SELECT n.*, IFNULL(u.username, '系统官方') as author_name " +
            "FROM wf_node_market n " +
            "LEFT JOIN user u ON n.author_id = u.id " +
            "WHERE n.status = #{status} " +
            "ORDER BY n.id DESC")
    List<WfNodeMarket> getNodesByStatus(@Param("status") int status);

    /**
     * 👑 核心：用户发布自定义节点（默认状态为0-待审核）
     */
    @Insert("INSERT INTO wf_node_market(name, provider, description, token_cost, icon, system_prompt, author_id, status, create_time) " +
            "VALUES(#{name}, #{provider}, #{description}, #{tokenCost}, #{icon}, #{systemPrompt}, #{authorId}, 0, NOW())")
    int insertNode(WfNodeMarket node);

    /**
     * 👑 管理员审核：更新节点状态
     */
    @Update("UPDATE wf_node_market SET status = #{status} WHERE id = #{id}")
    int updateNodeStatus(@Param("id") int id, @Param("status") int status);

    /**
     * 👑 删除节点（仅作者本人可调用）
     */
    @Delete("DELETE FROM wf_node_market WHERE id = #{id}")
    int deleteNodeById(@Param("id") int id);
}