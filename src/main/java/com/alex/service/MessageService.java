package com.alex.service;

import com.alex.pojo.Message;
import java.util.List;

public interface MessageService {
    List<Message> getMessagesByUserId(int userId);

    List<Message> getMessagesByUserIdAndType(int userId, String type);

    boolean createMessage(Message message);

    int getUnreadCount(int userId);

    boolean markAllAsRead(int userId);

    /** 📢 全站广播：向所有用户插入同一条消息，返回成功插入的行数 */
    int broadcastToAll(Message message);

    /** 🔔 获取用户最新一条未读消息 */
    Message getLatestUnread(int userId);
}