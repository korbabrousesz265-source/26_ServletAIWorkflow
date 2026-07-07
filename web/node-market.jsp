<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">AI 节点市场</h2>
                    <div class="text-muted mt-1">探索并组合不同的 AI 能力，构建你的专属自动化工作流。</div>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <div class="d-flex">
                        <div class="me-3">
                            <select class="form-select">
                                <option value="all">所有分类</option>
                                <option value="text">文本处理</option>
                                <option value="vision">图像视觉</option>
                                <option value="data">数据分析</option>
                            </select>
                        </div>
                        <div class="input-icon">
                            <input type="text" class="form-control" placeholder="搜索节点...">
                            <span class="input-icon-addon"><i class="ti ti-search"></i></span>
                        </div>
                        <a href="publish-node.jsp" class="btn btn-primary d-none d-sm-inline-block">
                            <i class="ti ti-plus me-2"></i> 创造自定义节点
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row row-cards">

                <c:forEach var="node" items="${nodeList}">
                    <div class="col-md-6 col-lg-4">
                        <div class="card shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-3">
                                    <span class="avatar avatar-md bg-primary-lt rounded me-3">
                                        <i class="${node.icon}"></i>
                                    </span>
                                    <div>
                                        <div class="fw-bold fs-3">${node.name}</div>
                                        <div class="text-muted fs-5">
                                            提供商:
                                            <span class="${node.authorId == 0 ? 'text-blue fw-bold' : 'text-orange fw-bold'}">
                                                    ${node.authorId == 0 ? node.provider : node.authorName}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <p class="text-muted text-truncate" style="max-height: 3rem; white-space: normal;">${node.description}</p>
                            </div>
                            <div class="card-footer d-flex align-items-center bg-light">
                                <span class="badge bg-green-lt">消耗: ${node.tokenCost} Token</span>
                                <div class="ms-auto">
                                    <a href="node-market?action=detail&id=${node.id}" class="btn btn-sm btn-outline-primary">查看详情</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>



            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />