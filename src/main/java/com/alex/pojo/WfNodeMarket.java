package com.alex.pojo;

public class WfNodeMarket {
    private int id;
    private String name;
    private String provider;
    private String description;
    private int tokenCost;
    private String icon;
    private String systemPrompt;

    private int authorId;

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public int getAuthorId() {
        return authorId;
    }

    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    private String createTime;
    private String authorName; // 关联查询出的用户名


    public WfNodeMarket() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getTokenCost() { return tokenCost; }
    public void setTokenCost(int tokenCost) { this.tokenCost = tokenCost; }
    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }
    public String getSystemPrompt() {        return systemPrompt;    }



    public void setSystemPrompt(String systemPrompt) {        this.systemPrompt = systemPrompt;    }
}