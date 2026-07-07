package com.alex.servlet;

import com.alex.service.WfAdminService;
import com.alex.service.impl.WfAdminServiceImpl;
import com.alex.service.WfHistoryLogService;
import com.alex.service.impl.WfHistoryLogServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/audit")
public class AdminLogServlet extends BaseServlet {

    private WfAdminService adminService = new WfAdminServiceImpl();
    private WfHistoryLogService logService = new WfHistoryLogServiceImpl();

    protected String index(HttpServletRequest request, HttpServletResponse response) {
        // 1. 注入大盘核心指标
        request.setAttribute("totalUsers", adminService.getTotalUserCount());
        request.setAttribute("totalTokens", adminService.getTotalTokensConsumed());
        request.setAttribute("totalCalls", adminService.getTotalAiCalls());

        // 2. 统计趋势图数据转 JSON
        request.setAttribute("trendData", new com.google.gson.Gson().toJson(adminService.getRecentCallTrend()));

        // 3. 审计列表
        request.setAttribute("allLogs", logService.selectAllLogs());

        return "/admin-audit.jsp";
    }
}