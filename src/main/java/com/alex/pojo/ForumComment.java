package com.alex.pojo;

public class ForumComment {
    private int id;
    private int postId;
    private int userId;
    private String content;
    private String createTime;

    private String userName; // 👑 核心：用于联表查询时接收评论者的用户名

    public ForumComment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}