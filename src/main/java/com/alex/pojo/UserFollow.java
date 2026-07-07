package com.alex.pojo;

public class UserFollow {
    private int followerId; // 粉丝ID [cite: 96]
    private int followedId; // 被关注的博主ID [cite: 96]
    private String createTime;

    public UserFollow() {}

    public int getFollowerId() { return followerId; }
    public void setFollowerId(int followerId) { this.followerId = followerId; }
    public int getFollowedId() { return followedId; }
    public void setFollowedId(int followedId) { this.followedId = followedId; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}