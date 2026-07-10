package com.alex.service;

import com.alex.pojo.WfNodeMarket;
import java.util.List;

public interface WfNodeMarketService {
    // 获取所有节点（管理员审核用）
    List<WfNodeMarket> getAllNodes();
    // 仅获取已通过审核的节点（节点市场展示用）
    List<WfNodeMarket> getApprovedNodes();
    // 执行工作流时，根据 ID 提取系统级 Prompt
    WfNodeMarket getNodeById(int id);
    boolean insertNode(WfNodeMarket node);
    boolean deleteNodeById(int id);
    // 管理员审核：更新节点状态
    boolean updateNodeStatus(int id, int status);
}