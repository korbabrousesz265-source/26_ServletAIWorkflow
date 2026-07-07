<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">运行审计日志</h2>
                    <div class="text-muted mt-1">记录你所有的工作流执行轨迹与 Token 消耗。</div>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <button class="btn btn-primary d-none d-sm-inline-block">
                        <i class="ti ti-download me-2"></i> 导出报表
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <div class="divide-y">
                                <c:forEach var="log" items="${logList}">
                                    <div>
                                        <div class="row">
                                            <div class="col-auto">
                                                <span class="avatar bg-${log.tokenUsed > 0 ? 'green' : 'blue'}-lt">
                                                    <i class="ti ti-${log.tokenUsed > 0 ? 'check' : 'server'}"></i>
                                                </span>
                                            </div>
                                            <div class="col">
                                                <div class="text-truncate">
                                                    执行了 <strong>${log.workflowName}</strong> 中的 <strong class="text-primary">[${log.nodeName}]</strong> 节点
                                                </div>
                                                <div class="text-muted mt-1">
                                                    消耗 Token: <span class="text-warning fw-bold">${log.tokenUsed}</span>
                                                    <span class="mx-2">·</span>
                                                    耗时: <span class="text-secondary">${log.duration} ms</span>
                                                </div>
                                            </div>
                                            <div class="col-auto align-self-center text-muted">
                                                <i class="ti ti-clock me-1"></i>${log.createTime}
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty logList}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="ti ti-ghost fs-1 d-block mb-3"></i>
                                        <p>您还没有执行过任何工作流节点，快去工作台试试吧！</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />