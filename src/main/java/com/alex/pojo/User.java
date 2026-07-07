package com.alex.pojo;

public class User {
    private int id;
    private String username;
    private String email;
    private String password;
    private int roleId;         // 👑 修正：roleID -> roleId，完美匹配数据库的 role_id
    private int isBlocked;      // 对应数据库的 is_blocked
    private String createTime;  // 对应数据库的 create_time

    public User() {}

    // --- 智能对齐后的 Getter & Setter ---
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public int getIsBlocked() { return isBlocked; }
    public void setIsBlocked(int isBlocked) { this.isBlocked = isBlocked; }

    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}