package com.alex.servlet;

import com.alex.mapper.WfNodeMarketMapper;
import com.alex.pojo.WfNodeMarket;
import com.alex.utils.MyBatisUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;
import com.alex.service.WfNodeMarketService;
import com.alex.service.impl.WfNodeMarketServiceImpl;

@WebServlet("/node-market")
public class NodeMarketServlet extends BaseServlet {
    private WfNodeMarketService nodeMarketService = new WfNodeMarketServiceImpl();

    protected String index(HttpServletRequest request, HttpServletResponse response) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            WfNodeMarketMapper mapper = sqlSession.getMapper(WfNodeMarketMapper.class);
            request.setAttribute("nodeList", mapper.getAllNodes());
        }
        return "/node-market.jsp";
    }

    // 👑 新增：节点详情查看
    protected String detail(HttpServletRequest request, HttpServletResponse response) {
        String idStr = request.getParameter("id");
        if (idStr == null) return "redirect:node-market";

        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            WfNodeMarketMapper mapper = sqlSession.getMapper(WfNodeMarketMapper.class);
            WfNodeMarket node = mapper.getNodeById(Integer.parseInt(idStr));
            request.setAttribute("node", node);
        } catch (Exception e) { e.printStackTrace(); }
        return "/node-detail.jsp"; // 转发到专门的节点详情页
    }

    // 👑 新增：接收用户发布的自定义节点
    protected String add(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        String username = (String) request.getSession().getAttribute("username");
        if (userId == null) return "redirect:login.jsp";

        WfNodeMarket node = new WfNodeMarket();
        node.setName(request.getParameter("name"));
        // 自动带上 @ 符号，彰显创作者专属身份
        node.setProvider("@" + username);
        node.setDescription(request.getParameter("description"));
        node.setSystemPrompt(request.getParameter("systemPrompt"));
        node.setIcon(request.getParameter("icon"));

        // 👑 架构师修复：防御性编程！如果前端作妖没传值，我们默认给它算 500 消耗，而不是直接崩溃！
        String tokenCostStr = request.getParameter("tokenCost");
        int cost = (tokenCostStr != null && !tokenCostStr.trim().isEmpty()) ? Integer.parseInt(tokenCostStr) : 500;
        node.setTokenCost(cost);

        node.setTokenCost(Integer.parseInt(request.getParameter("tokenCost")));
        node.setAuthorId(userId);

        if (nodeMarketService.insertNode(node)) {
            request.getSession().setAttribute("msg", "🎉 恭喜！你的自定义 AI 节点已成功发布到市场！");
        } else {
            request.getSession().setAttribute("msg", "❌ 发布失败，请检查输入格式。");
        }

        return "redirect:node-market"; // 重新加载节点市场
    }

}