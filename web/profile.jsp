<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    .smooth-panel-card {
        transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        border: 1px solid rgba(101, 116, 141, 0.12) !important;
    }
    /* 鼠标滑过时：平滑上浮 + 柔和色彩投影 */
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

                        <a href="/admin/posts" class="card text-decoration-none smooth-panel-card mb-3 shadow-none">
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
                    </c:if>
                </div>

                <div class="col-12 col-lg-8">
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

                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h3 class="card-title"><i class="ti ti-key me-2 text-warning"></i>个人私有云算力密钥配置</h3>
                        </div>
                        <div class="card-body">
                            <form action="profile" method="post">
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
                </div>

            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />