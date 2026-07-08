package com.alex.servlet;

import com.alex.pojo.Message;
import com.alex.service.MessageService;
import com.alex.service.impl.MessageServiceImpl;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/messages")
public class MessageServlet extends BaseServlet {

    private MessageService messageService = new MessageServiceImpl();

    // 1. 默认展示消息列表（支持按类型筛选）
    protected String index(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) return "redirect:login.jsp";

        String type = request.getParameter("type"); // like / comment / system / null=全部

        if (type != null && !type.isEmpty()) {
            request.setAttribute("msgList", messageService.getMessagesByUserIdAndType(userId, type));
        } else {
            request.setAttribute("msgList", messageService.getMessagesByUserId(userId));
        }

        request.setAttribute("currentType", type);
        request.setAttribute("unreadCount", messageService.getUnreadCount(userId));
        return "/messages.jsp";
    }

    // 2. 👑 一键已读动作
    protected String readAll(HttpServletRequest request, HttpServletResponse response) {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId != null) {
            messageService.markAllAsRead(userId);
        }
        String type = request.getParameter("type");
        if (type != null && !type.isEmpty()) {
            return "redirect:messages?action=index&type=" + type;
        }
        return "redirect:messages?action=index";
    }

    // 3. 👑 AJAX 获取未读消息数量（返回 JSON）
    protected String unreadCount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        int count = 0;
        if (userId != null) {
            count = messageService.getUnreadCount(userId);
        }
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.write("{\"count\":" + count + "}");
        out.flush();
        return null; // 自己处理了响应，基类无需再转发
    }

    // 4. 👑 管理员发送系统消息给指定用户
    protected String sendSystemMsg(HttpServletRequest request, HttpServletResponse response) {
        Integer adminId = (Integer) request.getSession().getAttribute("userId");
        if (adminId == null) return "redirect:login.jsp";

        String targetUserIdStr = request.getParameter("targetUserId");
        String title = request.getParameter("title");
        String content = request.getParameter("content");

        if (targetUserIdStr != null && title != null && content != null) {
            Message msg = new Message();
            msg.setUserId(Integer.parseInt(targetUserIdStr));
            msg.setType("system");
            msg.setIcon("alert-triangle");
            msg.setTitle(title);
            msg.setContent(content);
            msg.setLink("messages?action=index&type=system");
            messageService.createMessage(msg);
        }
        return "redirect:messages?action=index";
    }
}