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
                    <a href="#" class="btn btn-link text-muted">全部标记为已读</a>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-9">
                    <div class="card shadow-sm">
                        <div class="list-group list-group-flush list-group-hoverable">

                            <c:forEach var="msg" items="${msgList}">
                                <div class="list-group-item">
                                    <div class="row align-items-center">
                                        <div class="col-auto">
                                            <span class="badge bg-${msg.type == 'system' ? 'red' : 'blue'}"></span>
                                        </div>
                                        <div class="col-auto">
                                            <span class="avatar avatar-sm rounded bg-light">
                                                <i class="ti ti-${msg.icon}"></i>
                                            </span>
                                        </div>
                                        <div class="col text-truncate">
                                            <a href="${msg.link}" class="text-reset d-block fw-bold">${msg.title}</a>
                                            <div class="d-block text-muted text-truncate mt-n1">${msg.content}</div>
                                        </div>
                                        <div class="col-auto text-muted fs-5">${msg.time}</div>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty msgList}">
                                <div class="list-group-item">
                                    <div class="row align-items-center">
                                        <div class="col-auto"><span class="badge bg-red"></span></div> <div class="col-auto"><span class="avatar avatar-sm rounded bg-blue-lt text-blue"><i class="ti ti-thumb-up"></i></span></div>
                                        <div class="col text-truncate">
                                            <span class="text-reset d-block fw-bold">新点赞提醒</span>
                                            <div class="d-block text-muted text-truncate mt-n1">用户 <strong>Echo</strong> 点赞了你的模板《自动化小红书文案生成器》</div>
                                        </div>
                                        <div class="col-auto text-muted fs-5">刚刚</div>
                                    </div>
                                </div>
                                <div class="list-group-item">
                                    <div class="row align-items-center">
                                        <div class="col-auto"><span class="badge bg-red"></span></div>
                                        <div class="col-auto"><span class="avatar avatar-sm rounded bg-purple-lt text-purple"><i class="ti ti-message-2"></i></span></div>
                                        <div class="col text-truncate">
                                            <span class="text-reset d-block fw-bold">新评论提醒</span>
                                            <div class="d-block text-muted text-truncate mt-n1">用户 <strong>Albert</strong> 在你的模板下留言：“希望增加对 DeepSeek 的支持！”</div>
                                        </div>
                                        <div class="col-auto text-muted fs-5">2 小时前</div>
                                    </div>
                                </div>
                                <div class="list-group-item">
                                    <div class="row align-items-center">
                                        <div class="col-auto"><span class="badge bg-gray-300"></span></div> <div class="col-auto"><span class="avatar avatar-sm rounded bg-orange-lt text-orange"><i class="ti ti-alert-triangle"></i></span></div>
                                        <div class="col text-truncate">
                                            <span class="text-reset d-block fw-bold text-muted">系统通知：接口维护</span>
                                            <div class="d-block text-muted text-truncate mt-n1">由于 OpenAI 官方维护，今日凌晨 2:00-4:00 核心引擎调用可能会出现延迟。</div>
                                        </div>
                                        <div class="col-auto text-muted fs-5">昨天</div>
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

<jsp:include page="footer.jsp" />