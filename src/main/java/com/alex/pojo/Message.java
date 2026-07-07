package com.alex.pojo;

public class Message {
    private int id;
    private int userId;     // 👑 必须补上的核心外键：这条消息属于哪个用户
    private String type;
    private String icon;
    private String title;
    private String content;
    private String link;
    private String createTime;
    private int isRead;

    public Message() {}

    // 更新后的全参构造器
    public Message(int id, int userId, String type, String icon, String title, String content, String link, String createTime, int isRead) {
        this.id = id;
        this.userId = userId;
        this.type = type;
        this.icon = icon;
        this.title = title;
        this.content = content;
        this.link = link;
        this.createTime = createTime;
        this.isRead = isRead;
    }

    // --- Getters & Setters ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
    public int getIsRead() { return isRead; }
    public void setIsRead(int isRead) { this.isRead = isRead; }
}