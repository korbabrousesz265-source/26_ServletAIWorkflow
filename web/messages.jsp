<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">消息通知中心</h2>
                </div>
                <div class="col-auto ms-auto">
                    <c:if test="${not empty msgList}">
                        <a href="messages?action=readAll<c:if test='${not empty currentType}'>&type=${currentType}</c:if>" class="btn btn-outline-primary btn-sm">
                            <i class="ti ti-checks me-1"></i>全部标记为已读
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-9">

                    <!-- 消息类型 Tab 导航 -->
                    <div class="card shadow-sm mb-3">
                        <div class="card-body py-2">
                            <ul class="nav nav-pills">
                                <li class="nav-item">
                                    <a class="nav-link ${empty currentType ? 'active' : ''}" href="messages?action=index">
                                        <i class="ti ti-bell me-1"></i>全部
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'like' ? 'active' : ''}" href="messages?action=index&type=like">
                                        <i class="ti ti-thumb-up me-1"></i>点赞
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'comment' ? 'active' : ''}" href="messages?action=index&type=comment">
                                        <i class="ti ti-message-2 me-1"></i>评论
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'system' ? 'active' : ''}" href="messages?action=index&type=system">
                                        <i class="ti ti-alert-triangle me-1"></i>系统
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'announcement' ? 'active' : ''}" href="messages?action=index&type=announcement">
                                        <i class="ti ti-speakerphone me-1"></i>公告
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'warning' ? 'active' : ''}" href="messages?action=index&type=warning">
                                        <i class="ti ti-alert-triangle me-1"></i>警告
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link ${currentType == 'reward' ? 'active' : ''}" href="messages?action=index&type=reward">
                                        <i class="ti ti-gift me-1"></i>福利
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <!-- 消息列表 -->
                    <div class="card shadow-sm">
                        <div class="list-group list-group-flush list-group-hoverable">

                            <c:forEach var="msg" items="${msgList}">
                                <a href="${msg.link}" class="list-group-item list-group-item-action ${msg.isRead == 0 ? 'list-group-item-unread' : ''}">
                                    <div class="row align-items-center">
                                        <!-- 未读标记 -->
                                        <div class="col-auto">
                                            <c:choose>
                                                <c:when test="${msg.isRead == 0}">
                                                    <span class="badge bg-blue" style="width:8px;height:8px;padding:0;border-radius:50%;"></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="display:inline-block;width:8px;"></span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <!-- 图标 -->
                                        <div class="col-auto">
                                            <c:choose>
                                                <c:when test="${msg.type == 'like'}">
                                                    <span class="avatar avatar-sm rounded bg-blue-lt text-blue">
                                                        <i class="ti ti-thumb-up"></i>
                                                    </span>
                                                </c:when>
                                                <c:when test="${msg.type == 'comment'}">
                                                    <span class="avatar avatar-sm rounded bg-purple-lt text-purple">
                                                        <i class="ti ti-message-2"></i>
                                                    </span>
                                                </c:when>
                                                <c:when test="${msg.type == 'system'}">
                                                    <span class="avatar avatar-sm rounded bg-orange-lt text-orange">
                                                        <i class="ti ti-alert-triangle"></i>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="avatar avatar-sm rounded bg-light">
                                                        <i class="ti ti-${msg.icon}"></i>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <!-- 标题 + 内容 -->
                                        <div class="col text-truncate">
                                            <span class="text-reset d-block ${msg.isRead == 0 ? 'fw-bold' : ''}">${msg.title}</span>
                                            <div class="d-block text-muted text-truncate mt-n1">${msg.content}</div>
                                        </div>

                                        <!-- 时间 -->
                                        <div class="col-auto text-muted fs-6">
                                            <small>${msg.createTime}</small>
                                        </div>
                                    </div>
                                </a>
                            </c:forEach>


                            <!-- 空状态 -->
                            <c:if test="${empty msgList}">
                                <div class="list-group-item">
                                    <div class="text-center py-5 text-muted">
                                        <i class="ti ti-inbox fs-1 d-block mb-2" style="font-size:3rem;"></i>
                                        <c:choose>
                                            <c:when test="${currentType == 'like'}">
                                                <p class="fs-4 fw-bold">暂无点赞通知</p>
                                                <p class="text-muted">当有人点赞你的帖子时，你会在这里收到通知</p>
                                            </c:when>
                                            <c:when test="${currentType == 'comment'}">
                                                <p class="fs-4 fw-bold">暂无评论通知</p>
                                                <p class="text-muted">当有人评论你的帖子时，你会在这里收到通知</p>
                                            </c:when>
                                            <c:when test="${currentType == 'system'}">
                                                <p class="fs-4 fw-bold">暂无系统消息</p>
                                                <p class="text-muted">系统维护公告和管理员消息会在这里显示</p>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="fs-4 fw-bold">暂无消息</p>
                                                <p class="text-muted">去社区逛逛，与其他用户互动吧！</p>
                                                <a href="forum" class="btn btn-primary mt-2">
                                                    <i class="ti ti-planet me-1"></i>前往模板社区
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:if>

                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- 未读消息样式 -->
<style>
    .list-group-item-unread {
        background-color: rgba(32, 107, 196, 0.03);
        border-left: 3px solid #206bc4;
    }
    .list-group-item-unread:hover {
        background-color: rgba(32, 107, 196, 0.06);
    }
</style>

<jsp:include page="footer.jsp" />