<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <div class="mb-1">
                        <ol class="breadcrumb" aria-label="breadcrumbs">
                            <li class="breadcrumb-item"><a href="forum?action=index">模板社区</a></li>
                            <li class="breadcrumb-item"><a href="/forum?action=index&category=${post.category}">${empty post.category ? '未分类' : post.category}</a></li>
                            <li class="breadcrumb-item active" aria-current="page">详情</li>
                        </ol>
                    </div>
                    <h2 class="page-title text-wrap">
                        ${empty post.title ? '未命名工作流模板' : post.title}
                    </h2>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <div class="btn-list">
                        <c:if test="${sessionScope.userId != null && post.authorId == sessionScope.userId}">
                            <a href="javascript:void(0)"
                               class="btn btn-outline-danger"
                               onclick="tablerConfirm('删除帖子', '确定要删除这篇帖子吗？评论和收藏数据将一并清除，此操作不可撤销。', function(){ location.href='forum?action=deletePost&id=${post.id}'; })">
                                <i class="ti ti-trash me-2"></i>删除帖子
                            </a>
                        </c:if>
                        <a href="chat?importTemplateId=${post.id}" class="btn btn-primary d-none d-sm-inline-block shadow-sm">
                            <i class="ti ti-download me-2"></i> 导入到我的工作台
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-9">

                    <div class="card mb-3 shadow-sm border-0">
                        <div class="card-body d-flex align-items-center py-3">
                            <span class="avatar avatar-md rounded-circle bg-blue-lt me-3">
                                ${not empty post.authorName ? post.authorName.substring(0,1) : 'U'}
                            </span>
                            <div class="flex-fill d-flex align-items-center">
                                <div>
                                    <div class="fw-bold fs-3">${empty post.authorName ? '匿名架构师' : post.authorName}</div>
                                    <div class="text-muted fs-5">发布于 ${post.createTime}</div>
                                </div>
                                <c:if test="${sessionScope.userId != null && sessionScope.userId != post.authorId}">
                                    <a href="forum?action=toggleFollow&authorId=${post.authorId}&postId=${post.id}"
                                       class="btn btn-sm ${isFollowed ? 'btn-secondary' : 'btn-primary'} ms-4 rounded-pill px-3">
                                            ${isFollowed ? '已关注' : '+ 关注作者'}
                                    </a>
                                </c:if>
                            </div>

                            <div>
                                <a href="forum?action=toggleFavorite&postId=${post.id}"
                                   class="btn ${isFavorited ? 'btn-pink' : 'btn-outline-secondary'}">
                                    <i class="ti ti-heart me-2 ${isFavorited ? '' : 'text-pink'}"></i>
                                    ${isFavorited ? '已收藏' : '收藏工作流'} (${favoriteCount})
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="card card-lg mb-4 shadow-sm border-0">
                        <div class="card-body markdown" style="min-height: 300px;">
                            <div class="text-dark" style="white-space: pre-wrap; font-size: 15px; line-height: 1.8;">${post.content}</div>
                        </div>
                    </div>

                    <div class="card shadow-sm border-0 mb-5">
                        <div class="card-header"><h3 class="card-title">讨论区 (${commentList.size()})</h3></div>
                        <div class="list-group list-group-flush list-group-hoverable">
                            <c:forEach var="comment" items="${commentList}">
                                <div class="list-group-item">
                                    <div class="row align-items-start">
                                        <div class="col-auto">
                                            <span class="avatar avatar-sm rounded bg-orange-lt">${comment.userName.substring(0,1)}</span>
                                        </div>
                                        <div class="col text-truncate">
                                            <span class="text-reset d-block fw-bold">${comment.userName}</span>
                                            <div class="d-block text-muted text-wrap mt-1">${comment.content}</div>
                                        </div>
                                        <div class="col-auto text-muted text-sm">${comment.createTime}</div>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty commentList}">
                                <div class="text-center py-4 text-muted">暂无讨论，来做第一个留言的人吧！</div>
                            </c:if>
                        </div>
                        <div class="card-footer bg-light">
                            <form action="forum?action=addComment" method="post" class="d-flex">
                                <input type="hidden" name="postId" value="${post.id}">
                                <input type="text" class="form-control me-3" name="commentContent" placeholder="写下你的想法或改进建议..." required>
                                <button type="submit" class="btn btn-primary">发送留言</button>
                            </form>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />