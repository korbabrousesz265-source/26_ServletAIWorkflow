<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="container-xl mt-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="mb-3">
                    <ol class="breadcrumb" aria-label="breadcrumbs">
                        <li class="breadcrumb-item"><a href="node-market">节点市场</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${node.name}</li>
                    </ol>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-body p-5">
                        <div class="d-flex align-items-center mb-4">
                            <span class="avatar avatar-xl bg-primary-lt rounded me-4"><i class="${node.icon} fs-1"></i></span>
                            <div>
                                <h1 class="fw-bold mb-1">${node.name}</h1>
                                <div class="text-muted fs-4">提供商: <strong>${node.provider}</strong> | 消耗: <span class="text-warning fw-bold">${node.tokenCost} Token</span> / 次</div>
                            </div>
                        </div>

                        <h3 class="mt-4 mb-2">能力描述</h3>
                        <p class="text-muted fs-4 lh-lg">${node.description}</p>

                        <h3 class="mt-5 mb-3 d-flex align-items-center">
                            <i class="ti ti-code text-primary me-2"></i> 底层系统级 Prompt (只读)
                        </h3>
                        <div class="bg-dark text-light p-4 rounded-3" style="font-family: monospace; white-space: pre-wrap; line-height: 1.6;">${node.systemPrompt}</div>

                    </div>
                    <div class="card-footer bg-light d-flex justify-content-between align-items-center">
                        <c:if test="${sessionScope.userId != null && node.authorId == sessionScope.userId}">
                            <a href="javascript:void(0)"
                               class="btn btn-outline-danger"
                               onclick="tablerConfirm('删除节点', '确定要删除节点「${node.name}」吗？此操作不可撤销。', function(){ location.href='node-market?action=delete&id=${node.id}'; })">
                                <i class="ti ti-trash me-2"></i>删除此节点
                            </a>
                        </c:if>
                        <c:if test="${sessionScope.userId == null || node.authorId != sessionScope.userId}">
                            <span></span>
                        </c:if>
                        <a href="chat" class="btn btn-primary"><i class="ti ti-player-play me-2"></i> 前往工作台使用此节点</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />