package com.alex.service;

import com.alex.pojo.WfNodeMarket;
import java.util.List;

public interface WfNodeMarketService {
    // 获取前端市场可用的节点（仅已审核通过 + 系统官方）
    List<WfNodeMarket> getAllNodes();
    // 获取后台管理全部节点（含待审核、已驳回）
    List<WfNodeMarket> getAllNodesForAdmin();
    // 按状态筛选节点
    List<WfNodeMarket> getNodesByStatus(int status);
    // 执行工作流时，根据 ID 提取系统级 Prompt
    WfNodeMarket getNodeById(int id);
    boolean insertNode(WfNodeMarket node);
    boolean deleteNodeById(int id);
    // 管理员审核：更新节点状态（通过/驳回）
    boolean updateNodeStatus(int id, int status);
}