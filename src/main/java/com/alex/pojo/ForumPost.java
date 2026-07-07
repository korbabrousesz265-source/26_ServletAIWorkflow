package com.alex.pojo;

public class ForumPost {
    private int id;
    private int authorId;           // 帖子作者ID [cite: 81]
    private String title;
    private String content;
    private String workflowSnapshot; // 👑 核心：用于反向渲染画板的 JSON 快照 [cite: 81]
    private String category;         // 所属分类 [cite: 81]
    private String createTime;
    // 在 ForumPost.java 中追加这个字段
    private String authorName; // 👑 核心：用于接收 Mapper 联表查询出的作者名称

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public ForumPost() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getWorkflowSnapshot() { return workflowSnapshot; }
    public void setWorkflowSnapshot(String workflowSnapshot) { this.workflowSnapshot = workflowSnapshot; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}