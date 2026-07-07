package com.alex.pojo;

public class WfHistoryLog {
    private int id;
    private int userId;
    private String workflowName;
    private String nodeName;
    private int tokenUsed;
    private int duration;
    private String createTime;

    public WfHistoryLog() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getWorkflowName() { return workflowName; }
    public void setWorkflowName(String workflowName) { this.workflowName = workflowName; }
    public String getNodeName() { return nodeName; }
    public void setNodeName(String nodeName) { this.nodeName = nodeName; }
    public int getTokenUsed() { return tokenUsed; }
    public void setTokenUsed(int tokenUsed) { this.tokenUsed = tokenUsed; }
    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}