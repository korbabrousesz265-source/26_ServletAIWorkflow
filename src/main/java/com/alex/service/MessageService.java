package com.alex.service;

import com.alex.pojo.Message;
import java.util.List;

public interface MessageService {
    List<Message> getMessagesByUserId(int userId);

    List<Message> getMessagesByUserIdAndType(int userId, String type);

    boolean createMessage(Message message);

    int getUnreadCount(int userId);

    boolean markAllAsRead(int userId);
}