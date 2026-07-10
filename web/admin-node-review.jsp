<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    /* System Prompt 展示区 */
    .prompt-preview {
        background: #1e293b;
        color: #e2e8f0;
        border-radius: 8px;
        padding: 16px 20px;
        font-family: 'Cascadia Code', 'Fira Code', 'JetBrains Mono', monospace;
        font-size: 0.875rem;
        line-height: 1.7;
        max-height: 240px;
        overflow-y: auto;
        white-space: pre-wrap;
        word-break: break-word;
        position: relative;
    }
    .prompt-preview::-webkit-scrollbar { width: 6px; }
    .prompt-preview::-webkit-scrollbar-thumb { background: #475569; border-radius: 3px; }

    /* 风险关键词高亮 */
    .risk-highlight {
        background: rgba(239, 68, 68, 0.25);
        border-bottom: 2px wavy #ef4444;
        padding: 1px 3px;
        border-radius: 2px;
    }

    /* 审核卡片动画 */
    .review-card {
        transition: all 0.3s ease;
        border-left: 4px solid transparent;
    }
    .review-card.status-0 { border-left-color: #f59e0b; }  /* 待审核 - 黄色 */
    .review-card.status-1 { border-left-color: #10b981; }  /* 已通过 - 绿色 */
    .review-card.status-2 { border-left-color: #ef4444; }  /* 已驳回 - 红色 */

    /* 筛选标签 */
    .filter-tab.active {
        background: #206bc4 !important;
        color: #fff !important;
    }

    /* 完整 Prompt 模态框 */
    .modal-prompt-full {
        background: #1e293b;
        color: #e2e8f0;
        border-radius: 12px;
        padding: 24px;
        font-family: 'Cascadia Code', 'Fira Code', monospace;
        font-size: 0.9rem;
        line-height: 1.8;
        max-height: 60vh;
        overflow-y: auto;
        white-space: pre-wrap;
    }

    /* 风险检测标签 */
    .risk-tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: 600;
    }
    .risk-tag.danger { background: #fef2f2; color: #dc2626; }
    .risk-tag.warning { background: #fffbeb; color: #d97706; }
    .risk-tag.safe { background: #f0fdf4; color: #16a34a; }
</style>

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">🛡️ 节点审核中心</h2>
                    <div class="text-muted mt-1">
                        审核用户提交的自定义 AI 节点，检查 System Prompt 是否包含违规词或 Prompt 注入攻击风险，审核通过后方可上架至前端节点市场。
                    </div>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <div class="d-flex gap-2">
                        <a href="/node-market" class="btn btn-outline-secondary" target="_blank">
                            <i class="ti ti-apps me-2"></i> 前端市场
                        </a>
                        <a href="/admin/broadcast?action=index" class="btn btn-outline-secondary">
                            <i class="ti ti-speakerphone me-2"></i> 广播中心
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">

            <%-- 消息提示 --%>
            <c:if test="${not empty sessionScope.msg}">
                <div class="alert alert-important alert-dismissible ${sessionScope.msg.contains('❌') ? 'alert-danger' : 'alert-success'}" role="alert">
                    <div class="d-flex">
                        <div><i class="ti ${sessionScope.msg.contains('❌') ? 'ti-alert-circle' : 'ti-check'} me-2 fs-2"></i></div>
                        <div class="fw-bold">${sessionScope.msg}</div>
                    </div>
                    <a class="btn-close" data-bs-dismiss="alert" aria-label="close"></a>
                </div>
                <c:remove var="msg" scope="session" />
            </c:if>

            <%-- ========== 审核指南卡片 ========== --%>
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-light">
                    <h3 class="card-title"><i class="ti ti-shield-check text-primary me-2"></i>审核指南</h3>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="d-flex align-items-start gap-2">
                                <span class="risk-tag danger"><i class="ti ti-alert-triangle"></i> 违规词</span>
                                <div class="text-muted small">
                                    检查 Prompt 中是否包含色情、暴力、政治敏感、诈骗引导等违法违规内容。
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="d-flex align-items-start gap-2">
                                <span class="risk-tag warning"><i class="ti ti-bug"></i> Prompt 注入</span>
                                <div class="text-muted small">
                                    检查是否包含「忽略上述指令」「DAN 越狱」「输出系统提示词」「roleplay 绕过限制」等注入攻击模式。
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="d-flex align-items-start gap-2">
                                <span class="risk-tag safe"><i class="ti ti-check"></i> 通过标准</span>
                                <div class="text-muted small">
                                    Prompt 功能明确、无违规内容、无不安全的指令覆盖行为，即可通过审核上架市场。
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ========== 筛选标签 ========== --%>
            <div class="d-flex gap-2 mb-4 flex-wrap">
                <a href="?action=index" class="btn btn-sm ${empty currentFilter ? 'btn-primary filter-tab active' : 'btn-outline-secondary'}">
                    <i class="ti ti-list me-1"></i> 全部节点
                </a>
                <a href="?action=index&status=0" class="btn btn-sm ${currentFilter eq '0' ? 'btn-warning filter-tab active' : 'btn-outline-warning'}">
                    <i class="ti ti-clock me-1"></i> 待审核
                    <span class="badge bg-yellow ms-1">${currentFilter eq '0' ? nodeList.size() : ''}</span>
                </a>
                <a href="?action=index&status=1" class="btn btn-sm ${currentFilter eq '1' ? 'btn-success filter-tab active' : 'btn-outline-success'}">
                    <i class="ti ti-check me-1"></i> 已通过
                </a>
                <a href="?action=index&status=2" class="btn btn-sm ${currentFilter eq '2' ? 'btn-danger filter-tab active' : 'btn-outline-danger'}">
                    <i class="ti ti-x me-1"></i> 已驳回
                </a>
            </div>

            <%-- ========== 节点审核列表 ========== --%>
            <c:if test="${empty nodeList}">
                <div class="empty">
                    <div class="empty-img"><i class="ti ti-mood-happy fs-1 text-muted"></i></div>
                    <p class="empty-title">暂无数据</p>
                    <p class="empty-subtitle text-muted">
                        <c:choose>
                            <c:when test="${currentFilter eq '0'}">没有待审核的节点，干得漂亮！</c:when>
                            <c:when test="${currentFilter eq '1'}">暂无已通过的节点</c:when>
                            <c:when test="${currentFilter eq '2'}">暂无被驳回的节点</c:when>
                            <c:otherwise>节点市场空空如也，等待第一位创作者提交</c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </c:if>

            <div class="d-flex flex-column gap-4">
                <c:forEach var="node" items="${nodeList}">
                    <div class="card shadow-sm review-card status-${node.status}">
                        <div class="card-header d-flex align-items-center bg-light">
                            <div class="d-flex align-items-center gap-3">
                                <span class="avatar avatar-sm bg-primary-lt">
                                    <i class="${not empty node.icon ? node.icon : 'ti ti-robot'} fs-2"></i>
                                </span>
                                <div>
                                    <div class="fw-bold fs-4">
                                        ${node.name}
                                        <c:choose>
                                            <c:when test="${node.status == 0}">
                                                <span class="badge bg-warning ms-2">⏳ 待审核</span>
                                            </c:when>
                                            <c:when test="${node.status == 1}">
                                                <span class="badge bg-success ms-2">✅ 已通过</span>
                                            </c:when>
                                            <c:when test="${node.status == 2}">
                                                <span class="badge bg-danger ms-2">🚫 已驳回</span>
                                            </c:when>
                                        </c:choose>
                                        <c:if test="${node.authorId == 0}">
                                            <span class="badge bg-blue-lt ms-1">系统官方</span>
                                        </c:if>
                                    </div>
                                    <div class="text-muted small">
                                        创作者：<strong>${not empty node.authorName ? node.authorName : node.provider}</strong>
                                        &nbsp;|&nbsp; 消耗：${node.tokenCost} Token
                                        &nbsp;|&nbsp; 提交时间：${node.createTime}
                                        &nbsp;|&nbsp; ID：${node.id}
                                    </div>
                                </div>
                            </div>
                            <div class="ms-auto d-flex gap-2">
                                <button type="button" class="btn btn-sm btn-outline-secondary"
                                        onclick="showFullPrompt('${node.id}')">
                                    <i class="ti ti-eye me-1"></i> 查看完整指令
                                </button>
                                <c:if test="${node.status == 0}">
                                    <a href="javascript:void(0)"
                                       class="btn btn-sm btn-success"
                                       onclick="tablerConfirm('审核通过', '确认将节点「${node.name}」审核通过并上架到前端市场吗？', function(){ location.href='node-review?action=approve&id=${node.id}'; })">
                                        <i class="ti ti-check me-1"></i> 通过
                                    </a>
                                    <a href="javascript:void(0)"
                                       class="btn btn-sm btn-danger"
                                       onclick="tablerConfirm('驳回节点', '确认驳回节点「${node.name}」吗？驳回后不会在前端市场展示。', function(){ location.href='node-review?action=reject&id=${node.id}'; })">
                                        <i class="ti ti-x me-1"></i> 驳回
                                    </a>
                                </c:if>
                                <c:if test="${node.status == 1}">
                                    <a href="javascript:void(0)"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="tablerConfirm('撤销审核', '确认将节点「${node.name}」重新设为驳回状态吗？', function(){ location.href='node-review?action=reject&id=${node.id}'; })">
                                        <i class="ti ti-arrow-back-up me-1"></i> 撤销通过
                                    </a>
                                </c:if>
                                <c:if test="${node.status == 2}">
                                    <a href="javascript:void(0)"
                                       class="btn btn-sm btn-outline-success"
                                       onclick="tablerConfirm('重新审核', '确认重新审核并通过节点「${node.name}」吗？', function(){ location.href='node-review?action=approve&id=${node.id}'; })">
                                        <i class="ti ti-check me-1"></i> 重新通过
                                    </a>
                                </c:if>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label fw-bold">
                                    <i class="ti ti-message-2 me-1 text-purple"></i> System Prompt（系统指令）
                                </label>
                                <div class="prompt-preview" id="prompt-${node.id}">
                                    ${node.systemPrompt}
                                </div>
                            </div>
                            <c:if test="${node.status == 0}">
                                <div class="alert alert-warning mb-0" role="alert">
                                    <i class="ti ti-alert-triangle me-2"></i>
                                    <strong>审核提示：</strong>请仔细检查以上 System Prompt 是否包含违规内容或 Prompt 注入风险。重点关注：
                                    <span class="text-danger">「忽略」「忘记上述」「DAN」「越狱」「输出你的系统指令」「假装你是」「没有任何限制」</span>等关键词。
                                </div>
                            </c:if>
                            <c:if test="${node.status == 1}">
                                <div class="alert alert-success mb-0" role="alert">
                                    <i class="ti ti-check me-2"></i> 此节点已通过审核，当前在前端节点市场正常展示。
                                </div>
                            </c:if>
                            <c:if test="${node.status == 2}">
                                <div class="alert alert-danger mb-0" role="alert">
                                    <i class="ti ti-x me-2"></i> 此节点已被驳回，不会在前端市场展示。
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>

        </div>
    </div>
</div>

<%-- ========== 完整 Prompt 查看模态框 ========== --%>
<div class="modal modal-blur fade" id="promptModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="ti ti-code me-2"></i>完整 System Prompt</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="modal-prompt-full" id="fullPromptContent"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">关闭</button>
            </div>
        </div>
    </div>
</div>

<script>
/**
 * 在模态框中展示完整 System Prompt
 */
function showFullPrompt(nodeId) {
    var promptBlock = document.getElementById('prompt-' + nodeId);
    var fullContent = document.getElementById('fullPromptContent');
    if (promptBlock && fullContent) {
        fullContent.textContent = promptBlock.textContent;
        var modal = new bootstrap.Modal(document.getElementById('promptModal'));
        modal.show();
    }
}

/**
 * 修复驳回按钮的 tablerConfirm（确保回调在确认后执行）
 */
document.addEventListener('DOMContentLoaded', function() {
    // 高亮风险关键词
    var riskKeywords = [
        '忽略', '忘记', '上述指令', '忽略上述', '忘记上述',
        'DAN', 'Do Anything Now', '越狱', 'jailbreak',
        '输出你的', '系统指令', 'system prompt', '你的提示词',
        '假装你是', 'act as if', '没有任何限制', 'no restrictions',
        '忽略所有规则', 'ignore all', '你是自由的', 'you are free',
        '开发者模式', 'developer mode', '上帝模式', 'god mode'
    ];

    document.querySelectorAll('.prompt-preview').forEach(function(el) {
        var html = el.innerHTML;
        riskKeywords.forEach(function(kw) {
            var regex = new RegExp('(' + kw.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
            html = html.replace(regex, '<span class="risk-highlight">$1</span>');
        });
        el.innerHTML = html;
    });
});
</script>

<jsp:include page="footer.jsp" />
