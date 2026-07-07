<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="container-xl py-4">
        <c:if test="${not empty sessionScope.msg}">
            <div class="alert alert-info alert-dismissible shadow-sm mb-3" role="alert">
                <div class="d-flex">
                    <div><i class="ti ti-info-circle me-2"></i></div>
                    <div>${sessionScope.msg}</div>
                </div>
                <a class="btn-close" data-bs-dismiss="alert" aria-label="close"></a>
            </div>
            <% session.removeAttribute("msg"); %>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-header bg-transparent py-3">
                <h3 class="card-title fw-bold text-muted">
                    <i class="ti ti-article me-2 text-indigo"></i> 共享工作流社区帖子审计
                </h3>
            </div>
            <div class="table-responsive">
                <table class="table table-vcenter card-table table-hover">
                    <thead>
                    <tr>
                        <th>帖子 ID</th>
                        <th>快照标题</th>
                        <th>发布作者</th>
                        <th>所属大区</th>
                        <th>快照大小 (Bytes)</th>
                        <th>创建时间</th>
                        <th class="w-1">精细管理</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="post" items="${allPosts}">
                        <tr>
                            <td><span class="text-secondary fw-bold"># ${post.id}</span></td>
                            <td class="fw-bold text-dark">${post.title}</td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <span class="avatar avatar-xs me-2 rounded bg-indigo-lt">${post.authorName.substring(0,1)}</span>
                                    <span>${post.authorName}</span>
                                </div>
                            </td>
                            <td><span class="badge bg-purple-lt">${post.category}</span></td>
                            <td class="text-secondary">
                                <i class="ti ti-code-square me-1"></i> ${post.snapshotLength} 字节
                            </td>
                            <td class="text-muted">${post.createTime}</td>
                            <td>
                                <a href="posts?action=delete&id=${post.id}"
                                   class="btn btn-sm btn-outline-danger fw-bold"
                                   onclick="return confirm('⚠️ 确定要下架该分享记录吗？此操作无法撤销！')">
                                    <i class="ti ti-trash me-1"></i> 强制下架
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty allPosts}">
                        <tr>
                            <td colspan="7" class="text-center py-5 text-muted">社区空空如也，暂无分享推文。</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<jsp:include page="footer.jsp" />