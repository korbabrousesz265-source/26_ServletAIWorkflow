package com.alex.servlet;

import com.alex.service.MessageService;
import com.alex.service.impl.MessageServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

    private MessageService messageService = new MessageServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession(false).getAttribute("userId");

        request.setAttribute("msgList", messageService.getMessagesByUserId(userId));
        request.getRequestDispatcher("messages.jsp").forward(request, response);
    }
}