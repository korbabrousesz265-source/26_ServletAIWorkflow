package com.alex.pojo;

import java.util.List;

/**
 * 👑 通用物理分页工具类
 */
public class PageBean<T> {
    private int currentPage;    // 当前页码
    private int pageSize;       // 每页显示的条数
    private int totalCount;     // 数据库里的总记录数
    private int totalPage;      // 总页数 (需要计算得出)
    private List<T> list;       // 当前页的数据集合

    public PageBean(int currentPage, int pageSize, int totalCount, List<T> list) {
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalCount = totalCount;
        this.list = list;
        // 💡 核心算法：计算总页数 (例如：10条记录，每页3条，总页数就是 4)
        this.totalPage = (int) Math.ceil((double) totalCount / pageSize);
    }

    // --- 以下全是 Getter 方法，必须有，否则 JSP 读不到 ---
    public int getCurrentPage() { return currentPage; }
    public int getPageSize() { return pageSize; }
    public int getTotalCount() { return totalCount; }
    public int getTotalPage() { return totalPage; }
    public List<T> getList() { return list; }
}