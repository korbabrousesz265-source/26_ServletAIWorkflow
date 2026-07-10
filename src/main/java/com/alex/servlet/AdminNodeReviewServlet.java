package com.alex.servlet;

import com.alex.pojo.WfNodeMarket;
import com.alex.service.WfNodeMarketService;
import com.alex.service.impl.WfNodeMarketServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.List;

/**
 * 🛡️ 节点审核中心
 * 管理员审核用户提交的自定义节点，检查 System Prompt 是否包含违规词或 Prompt 注入攻击风险
 */
@WebServlet("/admin/node-review")
public class AdminNodeReviewServlet extends BaseServlet {

    private WfNodeMarketService nodeMarketService = new WfNodeMarketServiceImpl();

    /**
     * 渲染节点审核管理页面
     */
    protected String index(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:/login.jsp";

        // 🔒 仅管理员可访问
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId > 2) {
            request.getSession().setAttribute("msg", "❌ 权限不足：仅管理员可访问节点审核功能");
            return "redirect:/chat";
        }

        // 按筛选条件加载节点列表
        String statusFilter = request.getParameter("status");
        List<WfNodeMarket> nodeList;
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            int status = Integer.parseInt(statusFilter);
            nodeList = nodeMarketService.getNodesByStatus(status);
        } else {
            nodeList = nodeMarketService.getAllNodesForAdmin();
        }
        request.setAttribute("nodeList", nodeList);
        request.setAttribute("currentFilter", statusFilter);

        return "/admin-node-review.jsp";
    }

    /**
     * ✅ 审核通过
     */
    protected String approve(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:/login.jsp";

        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId > 2) {
            request.getSession().setAttribute("msg", "❌ 权限不足");
            return "redirect:/chat";
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            request.getSession().setAttribute("msg", "❌ 缺少节点 ID");
        } else {
            int nodeId = Integer.parseInt(idStr);
            WfNodeMarket node = nodeMarketService.getNodeById(nodeId);
            if (node != null && nodeMarketService.updateNodeStatus(nodeId, 1)) {
                request.getSession().setAttribute("msg", "✅ 节点「" + node.getName() + "」已审核通过，现已上架至节点市场");
            } else {
                request.getSession().setAttribute("msg", "❌ 审核操作失败，请检查节点是否存在");
            }
        }

        return "redirect:/admin/node-review?action=index";
    }

    /**
     * 🚫 驳回节点
     */
    protected String reject(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:/login.jsp";

        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId > 2) {
            request.getSession().setAttribute("msg", "❌ 权限不足");
            return "redirect:/chat";
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            request.getSession().setAttribute("msg", "❌ 缺少节点 ID");
        } else {
            int nodeId = Integer.parseInt(idStr);
            WfNodeMarket node = nodeMarketService.getNodeById(nodeId);
            if (node != null && nodeMarketService.updateNodeStatus(nodeId, 2)) {
                request.getSession().setAttribute("msg", "🚫 节点「" + node.getName() + "」已被驳回，不会在前端市场展示");
            } else {
                request.getSession().setAttribute("msg", "❌ 驳回操作失败，请检查节点是否存在");
            }
        }

        return "redirect:/admin/node-review?action=index";
    }
}
