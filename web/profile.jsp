<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    .smooth-panel-card {
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        border: 1px solid rgba(101, 116, 141, 0.12) !important;
    }
    .smooth-panel-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 20px rgba(32, 107, 196, 0.08) !important;
        border-color: rgba(32, 107, 196, 0.3) !important;
        background-color: #fcfdfe !important;
    }
    .smooth-panel-card:active {
        transform: translateY(-1px);
    }
    .icon-box-accent {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: transform 0.3s ease;
    }
    .smooth-panel-card:hover .icon-box-accent {
        transform: scale(1.1);
    }
    .social-item {
        transition: all 0.2s ease;
        border-left: 3px solid transparent;
    }
    .social-item:hover {
        background-color: rgba(32, 107, 196, 0.03);
        border-left-color: #206bc4;
    }
    .unfollow-btn, .unfavorite-btn {
        transition: all 0.2s ease;
    }
    .unfollow-btn:hover, .unfavorite-btn:hover {
        transform: scale(1.05);
    }
    .empty-state-icon {
        font-size: 3.5rem;
        opacity: 0.3;
    }
</style>

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">个人中心</h2>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row row-cards">

                <!-- ========== 左侧栏：个人信息 + 管理入口 ========== -->
                <div class="col-12 col-lg-4">
                    <div class="card shadow-sm mb-3">
                        <div class="card-body p-4 text-center">
                            <span class="avatar avatar-xl mb-3 rounded bg-blue-lt">
                                <i class="ti ti-user fs-1"></i>
                            </span>
                            <h3 class="m-0 mb-1">${not empty sessionScope.username ? sessionScope.username : '访客'}</h3>
                            <div class="text-muted mb-3">${not empty sessionScope.email ? sessionScope.email : '未绑定邮箱'}</div>
                            <div>
                                <c:choose>
                                    <c:when test="${sessionScope.roleId == 1}"><span class="badge bg-red-lt fw-bold">系统架构师</span></c:when>
                                    <c:when test="${sessionScope.roleId == 2}"><span class="badge bg-blue-lt fw-bold">系统管理员</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary-lt">普通用户</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <c:if test="${sessionScope.roleId == 1 || sessionScope.roleId == 2}">
                        <div class="mb-2 mt-4">
                            <label class="form-label text-muted fw-bold uppercase-tracking-wider" style="font-size: 11px;">
                                <i class="ti ti-shield-check text-success me-1"></i> 内部管控面 / MANAGEMENT CONSOLE
                            </label>
                        </div>

                        <a href="/admin/audit" class="card text-decoration-none smooth-panel-card mb-2 shadow-none">
                            <div class="card-body p-3 d-flex align-items-center">
                                <div class="icon-box-accent rounded bg-blue-lt me-3">
                                    <i class="ti ti-dashboard fs-2"></i>
                                </div>
                                <div class="flex-fill">
                                    <div class="font-weight-medium text-dark">全站运行审计大盘</div>
                                    <div class="text-muted style-small" style="font-size: 12px;">监控全网算力开销与调用日志</div>
                                </div>
                                <i class="ti ti-chevron-right text-muted fs-3 ms-2"></i>
                            </div>
                        </a>

                        <a href="userServlet?action=index" class="card text-decoration-none smooth-panel-card mb-2 shadow-none">
                            <div class="card-body p-3 d-flex align-items-center">
                                <div class="icon-box-accent rounded bg-green-lt me-3">
                                    <i class="ti ti-users fs-2"></i>
                                </div>
                                <div class="flex-fill">
                                    <div class="font-weight-medium text-dark">用户账号权限管理</div>
                                    <div class="text-muted" style="font-size: 12px;">执行封禁屏蔽与RBAC角色分发</div>
                                </div>
                                <i class="ti ti-chevron-right text-muted fs-3 ms-2"></i>
                            </div>
                        </a>

                        <a href="/admin/nodes?action=index" class="card text-decoration-none smooth-panel-card mb-2 shadow-none">
                            <div class="card-body p-3 d-flex align-items-center">
                                <div class="icon-box-accent rounded bg-purple-lt me-3">
                                    <i class="ti ti-box fs-2"></i>
                                </div>
                                <div class="flex-fill">
                                    <div class="font-weight-medium text-dark">AI 节点资产审核</div>
                                    <div class="text-muted" style="font-size: 12px;">审核全站节点库，下架违规或低质量节点</div>
                                </div>
                                <i class="ti ti-chevron-right text-muted fs-3 ms-2"></i>
                            </div>
                        </a>

                        <a href="/admin/posts" class="card text-decoration-none smooth-panel-card mb-2 shadow-none">
                            <div class="card-body p-3 d-flex align-items-center">
                                <div class="icon-box-accent rounded bg-indigo-lt me-3">
                                    <i class="ti ti-article fs-2"></i>
                                </div>
                                <div class="flex-fill">
                                    <div class="font-weight-medium text-dark">社区共享资产审计</div>
                                    <div class="text-muted" style="font-size: 12px;">管理已发布的流图JSON快照记录</div>
                                </div>
                                <i class="ti ti-chevron-right text-muted fs-3 ms-2"></i>
                            </div>
                        </a>

                        <a href="/admin/broadcast?action=index" class="card text-decoration-none smooth-panel-card mb-3 shadow-none">
                            <div class="card-body p-3 d-flex align-items-center">
                                <div class="icon-box-accent rounded bg-yellow-lt me-3">
                                    <i class="ti ti-speakerphone fs-2"></i>
                                </div>
                                <div class="flex-fill">
                                    <div class="font-weight-medium text-dark">全站广播与触达中心</div>
                                    <div class="text-muted" style="font-size: 12px;">向全体用户推送公告或定向发送站内信</div>
                                </div>
                                <i class="ti ti-chevron-right text-muted fs-3 ms-2"></i>
                            </div>
                        </a>
                    </c:if>
                </div>

                <!-- ========== 右侧栏：API Key + 社交面板 ========== -->
                <div class="col-12 col-lg-8">
                    <!-- 操作提示 -->
                    <c:if test="${not empty sessionScope.msg}">
                        <div class="alert alert-success alert-dismissible shadow-sm" role="alert">
                            <div class="d-flex">
                                <div><i class="ti ti-check me-2"></i></div>
                                <div>${sessionScope.msg}</div>
                            </div>
                            <a class="btn-close" data-bs-dismiss="alert" aria-label="close"></a>
                        </div>
                        <% session.removeAttribute("msg"); %>
                    </c:if>

                    <!-- API Key 配置卡片 -->
                    <div class="card shadow-sm mb-3">
                        <div class="card-header">
                            <h3 class="card-title"><i class="ti ti-key me-2 text-warning"></i>个人私有云算力密钥配置</h3>
                        </div>
                        <div class="card-body">
                            <form action="profile" method="post">
                                <input type="hidden" name="action" value="saveApiKey">
                                <div class="mb-3">
                                    <label class="form-label">OpenAI API Key</label>
                                    <div class="input-group input-group-flat">
                                        <input type="password" class="form-control" name="openai_key" value="${openaiKey}" placeholder="sk-..." autocomplete="off">
                                        <span class="input-group-text">
                                            <a href="#" class="link-secondary" title="显示/隐藏" data-bs-toggle="tooltip"><i class="ti ti-eye"></i></a>
                                        </span>
                                    </div>
                                </div>
                                <div class="mb-4">
                                    <label class="form-label">DeepSeek API Key</label>
                                    <input type="text" class="form-control" name="deepseek_key" value="${deepseekKey}" placeholder="请输入你的 DeepSeek 密钥...">
                                </div>
                                <div class="form-footer text-end">
                                    <button type="submit" class="btn btn-warning fw-bold">
                                        <i class="ti ti-device-floppy me-2"></i> 保存密钥配置
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- ========== 社交关注 & 收藏面板 ========== -->
                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h3 class="card-title"><i class="ti ti-heart me-2 text-red"></i>社交与收藏</h3>
                        </div>

                        <!-- Tab 导航 -->
                        <div class="card-body pb-0">
                            <ul class="nav nav-pills" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-following" type="button" role="tab">
                                        <i class="ti ti-user-check me-1"></i>我关注的用户
                                        <span class="badge bg-blue-lt text-blue ms-1">${not empty followingList ? followingList.size() : 0}</span>
                                    </button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-favorites" type="button" role="tab">
                                        <i class="ti ti-bookmark me-1"></i>我收藏的帖子
                                        <span class="badge bg-yellow-lt text-yellow ms-1">${not empty favoritePostList ? favoritePostList.size() : 0}</span>
                                    </button>
                                </li>
                            </ul>
                        </div>

                        <!-- Tab 内容 -->
                        <div class="card-body">
                            <div class="tab-content">

                                <!-- Tab 1: 我关注的用户 -->
                                <div class="tab-pane fade show active" id="tab-following" role="tabpanel">
                                    <c:choose>
                                        <c:when test="${not empty followingList}">
                                            <div class="list-group list-group-flush">
                                                <c:forEach var="follow" items="${followingList}">
                                                    <div class="list-group-item social-item">
                                                        <div class="row align-items-center">
                                                            <div class="col-auto">
                                                                <span class="avatar avatar-sm rounded bg-blue-lt text-blue">
                                                                    <i class="ti ti-user"></i>
                                                                </span>
                                                            </div>
                                                            <div class="col text-truncate">
                                                                <span class="fw-bold text-reset">${follow.username}</span>
                                                                <div class="text-muted small">关注于 ${follow.followTime}</div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <a href="javascript:void(0)"
                                                                   class="btn btn-outline-danger btn-sm unfollow-btn"
                                                                   onclick="tablerConfirm('取消关注', '确定要取消关注 ${follow.username} 吗？', function(){ location.href='profile?action=unfollow&followedId=${follow.id}'; })">
                                                                    <i class="ti ti-user-minus me-1"></i>取消关注
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-5 text-muted">
                                                <i class="ti ti-user-search empty-state-icon d-block mb-3"></i>
                                                <p class="fs-4 fw-bold">还没有关注任何人</p>
                                                <p class="text-muted">去社区逛逛，发现有趣的创作者吧！</p>
                                                <a href="forum" class="btn btn-primary mt-2">
                                                    <i class="ti ti-planet me-1"></i>前往模板社区
                                                </a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Tab 2: 我收藏的帖子 -->
                                <div class="tab-pane fade" id="tab-favorites" role="tabpanel">
                                    <c:choose>
                                        <c:when test="${not empty favoritePostList}">
                                            <div class="list-group list-group-flush">
                                                <c:forEach var="fav" items="${favoritePostList}">
                                                    <div class="list-group-item social-item">
                                                        <div class="row align-items-center">
                                                            <div class="col-auto">
                                                                <span class="avatar avatar-sm rounded bg-yellow-lt text-yellow">
                                                                    <i class="ti ti-bookmark"></i>
                                                                </span>
                                                            </div>
                                                            <div class="col text-truncate">
                                                                <a href="forum?action=detail&id=${fav.id}" class="fw-bold text-reset text-decoration-none">${fav.title}</a>
                                                                <div class="text-muted small">
                                                                    <c:if test="${not empty fav.category}">
                                                                        <span class="badge bg-secondary-lt me-1">${fav.category}</span>
                                                                    </c:if>
                                                                    收藏于 ${fav.favTime}
                                                                </div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <a href="javascript:void(0)"
                                                                   class="btn btn-outline-danger btn-sm unfavorite-btn"
                                                                   onclick="tablerConfirm('取消收藏', '确定要取消收藏该帖子吗？', function(){ location.href='profile?action=unfavorite&postId=${fav.id}'; })">
                                                                    <i class="ti ti-bookmark-off me-1"></i>取消收藏
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-5 text-muted">
                                                <i class="ti ti-bookmark-off empty-state-icon d-block mb-3"></i>
                                                <p class="fs-4 fw-bold">还没有收藏任何帖子</p>
                                                <p class="text-muted">在社区中发现好内容时，点击收藏即可保存到这里</p>
                                                <a href="forum" class="btn btn-primary mt-2">
                                                    <i class="ti ti-planet me-1"></i>前往模板社区
                                                </a>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />