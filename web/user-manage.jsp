<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">系统用户管理</h2>
                    <div class="text-muted mt-1">管理系统内所有用户的资料、权限及账户状态。</div>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <form action="userServlet" method="get" class="d-flex">
                        <input type="hidden" name="action" value="search">
                        <div class="input-icon me-3">
                            <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="搜索用户名或邮箱...">
                            <span class="input-icon-addon"><i class="ti ti-search"></i></span>
                        </div>
                        <a href="#" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modal-user-add">
                            <i class="ti ti-user-plus me-2"></i> 添加新用户
                        </a>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">

            <c:if test="${not empty sessionScope.msg}">
                <div class="alert alert-important alert-dismissible ${sessionScope.msg.contains('❌') ? 'bg-danger' : 'bg-success'}" role="alert">
                    <div class="d-flex">
                        <div><i class="ti ${sessionScope.msg.contains('❌') ? 'ti-alert-circle' : 'ti-check'} me-2 fs-2"></i></div>
                        <div class="fw-bold">${sessionScope.msg}</div>
                    </div>
                    <a class="btn-close btn-close-white" data-bs-dismiss="alert" aria-label="close"></a>
                </div>
                <c:remove var="msg" scope="session" />
            </c:if>

            <div class="card shadow-sm">
                <div class="table-responsive">
                    <table class="table table-vcenter card-table table-striped">
                        <thead>
                        <tr>
                            <th>用户名</th>
                            <th>联系方式</th>
                            <th>系统角色</th>
                            <th>注册时间</th>
                            <th>账号状态</th>
                            <th class="w-1">操作</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${pageBean.list}" var="u">
                            <tr>
                                <td class="fw-bold">${u.username}</td>
                                <td class="text-muted">
                                    <div><i class="ti ti-mail me-1"></i>${u.email}</div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.roleId == 1}"><span class="badge bg-red-lt">系统管理员</span></c:when>
                                        <c:when test="${u.roleId == 2}"><span class="badge bg-blue-lt">管理员</span></c:when>
                                        <c:otherwise><span class="badge bg-secondary-lt">普通账号</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-muted">${u.createTime}</td>
                                <td>
                                    <c:if test="${u.isBlocked == 0}"><span class="status status-green">正常</span></c:if>
                                    <c:if test="${u.isBlocked == 1}"><span class="status status-red">已屏蔽</span></c:if>
                                </td>
                                <td>
                                    <c:if test="${u.isBlocked == 0}">
                                        <a href="javascript:void(0)" class="btn btn-sm btn-outline-danger" onclick="tablerConfirm('屏蔽用户', '确认要屏蔽该用户吗？', function(){ location.href='userServlet?action=block&userId=${u.id}&isBlocked=1'; })">屏蔽</a>
                                    </c:if>
                                    <c:if test="${u.isBlocked == 1}">
                                        <a href="javascript:void(0)" class="btn btn-sm btn-outline-success" onclick="tablerConfirm('恢复用户', '确认要恢复该用户吗？', function(){ location.href='userServlet?action=block&userId=${u.id}&isBlocked=0'; })">恢复</a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty pageBean.list}">
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="ti ti-ghost fs-1 d-block mb-2"></i> 没有找到任何用户数据
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="card-footer d-flex align-items-center bg-light">
                    <p class="m-0 text-muted">共 <span>${pageBean.totalCount}</span> 条记录，当前第 <span>${pageBean.currentPage} / ${pageBean.totalPage}</span> 页</p>
                    <ul class="pagination m-0 ms-auto">
                        <li class="page-item ${pageBean.currentPage == 1 ? 'disabled' : ''}">
                            <a class="page-link" href="userServlet?action=index&currentPage=${pageBean.currentPage - 1}&keyword=${keyword}">上一页</a>
                        </li>

                        <li class="page-item active"><a class="page-link" href="#">${pageBean.currentPage}</a></li>

                        <li class="page-item ${pageBean.currentPage == pageBean.totalPage || pageBean.totalPage == 0 ? 'disabled' : ''}">
                            <a class="page-link" href="userServlet?action=index&currentPage=${pageBean.currentPage + 1}&keyword=${keyword}">下一页</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal modal-blur fade" id="modal-user-add" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">添加新系统用户</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="userServlet?action=add" method="post">
                <div class="modal-body">
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label required">用户名</label>
                            <input type="text" name="username" class="form-control" placeholder="输入系统唯一用户名" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label required">邮箱地址</label>
                            <input type="email" name="email" class="form-control" placeholder="用于接收系统通知" required>
                        </div>
                    </div>
                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label required">分配系统角色</label>
                            <select class="form-select" name="roleId">
                                <option value="3" selected>普通账号 (仅使用前台功能)</option>
                                <option value="2">管理员 (日常管理权限)</option>
                                <option value="1">系统管理员 (最高权限)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label required">初始密码</label>
                            <input name="password" type="password" class="form-control" placeholder="设置初始登录密码" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="#" class="btn btn-link link-secondary" data-bs-dismiss="modal">取消</a>
                    <button type="submit" class="btn btn-primary ms-auto">
                        <i class="ti ti-plus me-2"></i> 确认添加并保存
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />