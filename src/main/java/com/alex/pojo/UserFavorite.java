package com.alex.pojo;

public class UserFavorite {
    private int userId;
    private int postId;
    private String createTime;

    public UserFavorite() {}

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}