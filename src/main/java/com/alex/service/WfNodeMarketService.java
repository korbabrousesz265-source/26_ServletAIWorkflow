package com.alex.service;

import com.alex.pojo.WfNodeMarket;
import java.util.List;

public interface WfNodeMarketService {
    // 获取画板左侧的所有可用节点
    List<WfNodeMarket> getAllNodes();
    // 执行工作流时，根据 ID 提取系统级 Prompt
    WfNodeMarket getNodeById(int id);
    boolean insertNode(WfNodeMarket node);
    boolean deleteNodeById(int id);
}