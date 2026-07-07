package com.alex.service;

import com.alex.pojo.Message;
import java.util.List;

public interface MessageService {
    List<Message> getMessagesByUserId(int userId);
}