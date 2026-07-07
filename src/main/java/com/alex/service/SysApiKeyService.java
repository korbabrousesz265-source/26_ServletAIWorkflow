package com.alex.service;

import com.alex.pojo.SysApiKey;

public interface SysApiKeyService {
    SysApiKey getApiKeyByUserId(int userId);
    boolean saveOrUpdateApiKey(SysApiKey apiKey);
}