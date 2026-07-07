package com.alex.pojo;

public class SysApiKey {
    private int userId;         // 👑 主外键合一，对应 user 表的 id [cite: 75]
    private String openaiKey;
    private String deepseekKey;

    public SysApiKey() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getOpenaiKey() { return openaiKey; }
    public void setOpenaiKey(String openaiKey) { this.openaiKey = openaiKey; }
    public String getDeepseekKey() { return deepseekKey; }
    public void setDeepseekKey(String deepseekKey) { this.deepseekKey = deepseekKey; }
}