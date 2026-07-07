package com.alex.servlet;

import com.alex.service.WfHistoryLogService;
import com.alex.service.impl.WfHistoryLogServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/history")
public class HistoryServlet extends BaseServlet {

    private WfHistoryLogService logService = new WfHistoryLogServiceImpl();

    protected String index(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            request.getSession().setAttribute("msg", "❌ 请先登录以查看运行日志！");
            return "redirect:login.jsp";
        }

        request.setAttribute("logList", logService.getLogsByUserId(userId));
        return "/history.jsp";
    }
}