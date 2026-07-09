<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    /* ========== 画板容器 ========== */
    .canvas-viewport {
        position: relative;
        width: 100%;
        height: 65vh;
        min-height: 500px;
        overflow: hidden;
        background: #f8f9fb;
        border: 1px solid #dce1e7;
        border-radius: 8px;
        cursor: grab;
        user-select: none;
        -webkit-user-select: none;
    }
    .canvas-viewport:active { cursor: grabbing; }
    .canvas-viewport.grabbing { cursor: grabbing; }
    .canvas-viewport.panning { cursor: move; }

    /* ========== 画板世界（可缩放平移） ========== */
    .canvas-world {
        position: absolute;
        top: 0; left: 0;
        width: 6000px; height: 6000px;
        transform-origin: 0 0;
        transition: none;
    }
    .canvas-world.smooth-transition {
        transition: transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    /* ========== 网格背景 ========== */
    .canvas-grid {
        position: absolute;
        top: 0; left: 0;
        width: 100%; height: 100%;
        background-image: radial-gradient(circle, #cdd4e0 1px, transparent 1px);
        background-size: 32px 32px;
        pointer-events: none;
    }

    /* ========== SVG 连线层（已废弃，改用管道拼接） ========== */

    /* ========== 画布节点 ========== */
    .canvas-node {
        position: absolute;
        width: 260px;
        background: #ffffff;
        border: 2px solid #dce1e7;
        border-radius: 8px;
        z-index: 10;
        cursor: auto;
        transition: box-shadow 0.2s, border-color 0.2s;
        box-shadow: 0 1px 6px rgba(0,0,0,0.08);
        font-size: 14px;
    }
    .canvas-node:hover {
        border-color: #90b3e0;
        box-shadow: 0 4px 16px rgba(32, 107, 196, 0.12);
    }
    .canvas-node.dragging {
        z-index: 100;
        opacity: 0.94;
        box-shadow: 0 12px 32px rgba(0,0,0,0.18);
        border-color: #206bc4;
    }
    .canvas-node.executing {
        border-color: #f59f00;
        box-shadow: 0 0 20px rgba(245, 159, 0, 0.22);
        animation: pulse-border 1.2s ease-in-out infinite;
    }
    .canvas-node.done {
        border-color: #2fb344;
        box-shadow: 0 0 12px rgba(47, 179, 68, 0.18);
    }
    .canvas-node.error {
        border-color: #d63939;
        box-shadow: 0 0 12px rgba(214, 57, 57, 0.18);
    }

    @keyframes pulse-border {
        0%, 100% { border-color: #f59f00; box-shadow: 0 0 14px rgba(245, 159, 0, 0.18); }
        50% { border-color: #fab005; box-shadow: 0 0 28px rgba(245, 159, 0, 0.35); }
    }

    /* ========== 节点头部 ========== */
    .canvas-node .node-header {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 12px;
        background: #f6f8fb;
        border-bottom: 1px solid #e5e7eb;
        border-radius: 6px 6px 0 0;
        cursor: grab;
        font-weight: 600;
        color: #1e293b;
    }
    .canvas-node.dragging .node-header { cursor: grabbing; }
    .canvas-node .node-step-badge {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 22px; height: 22px;
        background: #206bc4;
        color: #fff;
        border-radius: 6px;
        font-size: 11px;
        font-weight: 700;
        flex-shrink: 0;
    }
    .canvas-node .node-icon {
        font-size: 16px;
        color: #206bc4;
        flex-shrink: 0;
    }
    .canvas-node .node-title {
        flex: 1;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        font-size: 13px;
    }
    .canvas-node .node-status-dot {
        width: 10px; height: 10px;
        border-radius: 50%;
        flex-shrink: 0;
        background: #d0d5dd;
        transition: background 0.3s;
    }
    .canvas-node .node-status-dot.running { background: #f59f00; animation: blink-dot 0.6s ease-in-out infinite; }
    .canvas-node .node-status-dot.done { background: #2fb344; }
    .canvas-node .node-status-dot.error { background: #d63939; }

    @keyframes blink-dot {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.3; }
    }

    .canvas-node .btn-close-node {
        background: transparent;
        border: none;
        color: #9ca3af;
        cursor: pointer;
        font-size: 16px;
        padding: 0 2px;
        line-height: 1;
        flex-shrink: 0;
    }
    .canvas-node .btn-close-node:hover { color: #d63939; }

    /* ========== 节点主体 ========== */
    .canvas-node .node-body {
        padding: 8px 12px;
    }
    .canvas-node .node-type-select {
        width: 100%;
        padding: 6px 8px;
        background: #ffffff;
        color: #1e293b;
        border: 1px solid #dce1e7;
        border-radius: 5px;
        font-size: 12px;
        cursor: pointer;
    }
    .canvas-node .node-type-select:focus {
        border-color: #90b3e0;
        outline: none;
        box-shadow: 0 0 0 2px rgba(32, 107, 196, 0.1);
    }

    /* ========== 节点输出面板 ========== */
    .canvas-node .node-output-panel {
        display: none;
        border-top: 1px solid #e5e7eb;
        background: #fafbfc;
        border-radius: 0 0 6px 6px;
        max-height: 200px;
        overflow-y: auto;
    }
    .canvas-node .node-output-panel.expanded { display: block; }
    .canvas-node .node-output-content {
        padding: 8px 12px;
        font-size: 12px;
        color: #495057;
        white-space: pre-wrap;
        word-break: break-word;
        line-height: 1.5;
        font-family: 'SF Mono', 'Cascadia Code', 'Consolas', monospace;
    }
    .canvas-node .node-output-meta {
        display: flex;
        gap: 12px;
        padding: 5px 12px;
        font-size: 11px;
        color: #6c757d;
        background: #f1f3f5;
    }
    .canvas-node .btn-expand-output {
        background: transparent;
        border: none;
        color: #206bc4;
        cursor: pointer;
        font-size: 11px;
        padding: 2px 8px;
    }

    /* ========== 管道连接箭头 ========== */
    .pipeline-connector {
        position: absolute;
        z-index: 5;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        pointer-events: none;
    }
    .pipeline-connector .connector-line {
        flex: 1;
        height: 2px;
        background: #206bc4;
        opacity: 0.5;
    }
    .pipeline-connector .connector-arrow {
        font-size: 16px;
        color: #206bc4;
        opacity: 0.7;
        flex-shrink: 0;
    }

    /* ========== 侧边栏（节点面板） ========== */
    .node-palette {
        background: #ffffff;
        border-radius: 8px;
        border: 1px solid #dce1e7;
        overflow: hidden;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .node-palette .palette-header {
        padding: 12px 16px;
        border-bottom: 1px solid #e5e7eb;
        font-weight: 600;
        font-size: 14px;
        color: #1e293b;
        display: flex;
        align-items: center;
        gap: 8px;
        background: #fafbfc;
    }
    .node-palette .palette-search {
        padding: 10px 16px;
    }
    .node-palette .palette-search input {
        width: 100%;
        padding: 8px 10px;
        background: #ffffff;
        color: #1e293b;
        border: 1px solid #dce1e7;
        border-radius: 6px;
        font-size: 13px;
    }
    .node-palette .palette-search input:focus {
        border-color: #90b3e0;
        outline: none;
        box-shadow: 0 0 0 3px rgba(32, 107, 196, 0.1);
    }
    .node-palette .palette-list {
        max-height: 400px;
        overflow-y: auto;
        padding: 8px;
    }
    .node-palette .palette-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 12px;
        border-radius: 8px;
        cursor: pointer;
        transition: background 0.15s;
        color: #1e293b;
        font-size: 13px;
        border: 1px solid transparent;
    }
    .node-palette .palette-item:hover {
        background: #f0f4ff;
        border-color: #d0ddf5;
    }
    .node-palette .palette-item .pi-icon {
        font-size: 20px;
        color: #206bc4;
        flex-shrink: 0;
        width: 28px;
        text-align: center;
    }
    .node-palette .palette-item .pi-info {
        flex: 1;
        min-width: 0;
    }
    .node-palette .palette-item .pi-name {
        font-weight: 600;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .node-palette .palette-item .pi-desc {
        font-size: 11px;
        color: #6c757d;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .node-palette .palette-item.ppt-item {
        border-left: 3px solid #f59f00;
    }

    /* ========== 工具栏 ========== */
    .canvas-toolbar {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
    }
    .canvas-toolbar .btn {
        font-size: 13px;
    }

    /* ========== 底部输出面板 ========== */
    .final-output-panel {
        background: #ffffff;
        border: 1px solid #dce1e7;
        border-radius: 8px;
        overflow: hidden;
        margin-top: 16px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .final-output-panel .output-header {
        padding: 10px 16px;
        background: #fafbfc;
        border-bottom: 1px solid #e5e7eb;
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
        color: #1e293b;
        font-weight: 600;
        font-size: 14px;
    }

    /* ========== 缩放控件 ========== */
    .zoom-controls {
        position: absolute;
        bottom: 16px;
        right: 16px;
        display: flex;
        flex-direction: column;
        gap: 4px;
        z-index: 50;
    }
    .zoom-controls button {
        width: 36px; height: 36px;
        border-radius: 8px;
        border: 1px solid #dce1e7;
        background: #ffffff;
        color: #495057;
        cursor: pointer;
        font-size: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: background 0.15s, border-color 0.15s;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    }
    .zoom-controls button:hover {
        background: #f0f4ff;
        border-color: #206bc4;
        color: #206bc4;
    }
    .zoom-controls .zoom-label {
        text-align: center;
        font-size: 11px;
        color: #6c757d;
        padding: 4px 0;
    }

    /* ========== 操作提示 ========== */
    .canvas-hint {
        position: absolute;
        bottom: 20px;
        left: 50%;
        transform: translateX(-50%);
        color: #adb5bd;
        font-size: 12px;
        pointer-events: none;
        z-index: 5;
    }

    /* ========== 初始输入区 ========== */
    .initial-input-area {
        background: #ffffff;
        border: 1px solid #dce1e7;
        border-radius: 8px;
        padding: 16px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.04);
    }
    .initial-input-area textarea {
        width: 100%;
        background: #ffffff;
        color: #1e293b;
        border: 1px solid #dce1e7;
        border-radius: 6px;
        padding: 12px;
        font-size: 14px;
        resize: vertical;
    }
    .initial-input-area textarea:focus {
        border-color: #90b3e0;
        outline: none;
        box-shadow: 0 0 0 3px rgba(32, 107, 196, 0.1);
    }
</style>

<div class="page-wrapper">
    <%-- 🔑 API Key 未配置警告 --%>
    <c:if test="${showApiKeyWarning}">
        <div class="container-xl mt-3">
            <div class="alert alert-warning alert-dismissible shadow-sm" role="alert">
                <div class="d-flex align-items-center">
                    <div class="me-3"><i class="ti ti-alert-triangle fs-1 text-warning"></i></div>
                    <div>
                        <h4 class="alert-title">⚠️ 尚未配置 API 密钥</h4>
                        <div class="text-muted">
                            你还没有配置个人 API Key，工作流将使用系统默认密钥运行。
                            为了获得更稳定的服务，建议前往
                            <a href="profile?action=index" class="btn btn-warning btn-sm ms-2 fw-bold">
                                <i class="ti ti-key me-1"></i>配置我的 API Key
                            </a>
                        </div>
                    </div>
                </div>
                <a class="btn-close" data-bs-dismiss="alert" aria-label="close"></a>
            </div>
        </div>
    </c:if>

    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col"><h2 class="page-title">AI 工作流中心</h2></div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row g-3">

                <%-- ========== 左侧节点面板 ========== --%>
                <div class="col-12 col-lg-2 order-lg-1">
                    <div class="d-flex flex-column gap-3">

                        <%-- 工具栏按钮 --%>
                        <div class="canvas-toolbar d-flex flex-wrap gap-2">
                            <button class="btn btn-sm btn-outline-secondary" onclick="saveToLocalCache()" title="保存到浏览器">
                                <i class="ti ti-device-floppy me-1"></i> 暂存
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="exportToFile()" title="导出 JSON">
                                <i class="ti ti-download me-1"></i> 导出
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="document.getElementById('importJsonInput').click()" title="导入 JSON">
                                <i class="ti ti-upload me-1"></i> 导入
                            </button>
                            <input type="file" id="importJsonInput" style="display:none" accept=".json" onchange="importFromFile(event)">
                            <button class="btn btn-sm btn-outline-danger" onclick="clearCanvas()" title="清空画板">
                                <i class="ti ti-trash me-1"></i>
                            </button>
                        </div>

                        <%-- 节点面板 --%>
                        <div class="node-palette">
                            <div class="palette-header">
                                <i class="ti ti-box text-primary"></i> AI 算力节点
                            </div>
                            <div class="palette-search">
                                <input type="text" id="paletteSearch" placeholder="搜索节点..." oninput="filterPalette()">
                            </div>
                            <div class="palette-list" id="paletteList">
                                <c:forEach var="tpl" items="${templates}">
                                    <div class="palette-item" data-node-id="${tpl.id}" data-node-name="${tpl.name}" data-node-desc="${tpl.description}" data-node-icon="${tpl.icon}">
                                        <i class="pi-icon ${tpl.icon}"></i>
                                        <div class="pi-info">
                                            <div class="pi-name">${tpl.name}</div>
                                            <div class="pi-desc">${tpl.description}</div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                        <%-- 插件节点面板 --%>
                        <div class="node-palette">
                            <div class="palette-header">
                                <i class="ti ti-plug text-warning"></i> 插件节点
                            </div>
                            <div class="palette-list">
                                <div class="palette-item ppt-item" data-node-id="-1" data-node-name="导出为 PowerPoint" data-node-desc="将 AI 生成的 JSON 渲染为 .pptx 文件并下载" data-node-icon="ti ti-file-powerpoint">
                                    <i class="pi-icon ti ti-file-powerpoint text-warning"></i>
                                    <div class="pi-info">
                                        <div class="pi-name">导出为 PowerPoint</div>
                                        <div class="pi-desc">渲染 JSON → .pptx 下载</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- 本地暂存列表 --%>
                        <div class="card shadow-sm border-primary" style="border-top: 2px solid #206bc4;">
                            <div class="card-header bg-light py-2">
                                <h3 class="card-title"><i class="ti ti-history me-2 text-primary"></i> 本地暂存</h3>
                            </div>
                            <div class="list-group list-group-flush" id="localWorkflowList" style="max-height: 200px; overflow-y: auto;">
                            </div>
                        </div>
                    </div>
                </div>

                <%-- ========== 画布区域 ========== --%>
                <div class="col-12 col-lg-7 order-lg-2">
                    <%-- 初始输入 --%>
                    <div class="initial-input-area mb-3">
                        <label class="form-label text-muted mb-2 fw-bold">
                            <i class="ti ti-edit me-1"></i> 初始任务内容
                        </label>
                        <textarea id="userTextInput" rows="2" placeholder="在此输入需要第一步处理的文本...">${param.userText}</textarea>
                    </div>

                    <%-- 画布 --%>
                    <div class="canvas-viewport" id="canvasViewport">
                        <div class="canvas-world" id="canvasWorld">
                            <div class="canvas-grid"></div>
                        </div>
                        <div class="canvas-hint" id="canvasHint">🖱️ 点击左侧节点添加到画布 | 滚轮缩放 | 拖拽空白平移 | 拖拽节点交换顺序</div>
                        <div class="zoom-controls">
                            <button onclick="zoomIn()" title="放大">+</button>
                            <div class="zoom-label" id="zoomLabel">100%</div>
                            <button onclick="zoomOut()" title="缩小">−</button>
                            <button onclick="resetView()" title="适应画布" style="font-size:14px;">⊞</button>
                        </div>
                    </div>

                    <%-- 执行按钮 --%>
                    <div class="d-flex gap-2 mt-3">
                        <button class="btn btn-primary btn-lg flex-fill fw-bold" id="btnExecute" onclick="executeWorkflow()">
                            <i class="ti ti-player-play me-2"></i> 启动自动化流转
                        </button>
                        <button class="btn btn-outline-secondary btn-lg" onclick="stopExecution()" id="btnStop" style="display:none;" title="停止执行">
                            <i class="ti ti-player-stop"></i>
                        </button>
                    </div>

                    <%-- 最终输出面板 --%>
                    <div class="final-output-panel" id="finalOutputPanel" style="display:none;">
                        <div class="output-header" onclick="toggleFinalOutput()">
                            <i class="ti ti-file-text text-primary"></i>
                            <span>最终输出结果</span>
                            <span class="ms-auto text-muted" style="font-size:12px;" id="outputMeta"></span>
                            <i class="ti ti-chevron-down ms-2" id="finalOutputChevron"></i>
                        </div>
                        <div class="p-3" id="finalOutputBody">
                            <div id="markdown-viewer" class="bg-light p-4 rounded-2" style="min-height: 120px; max-height: 400px; overflow-y: auto; font-size: 14px; border: 1px solid #e5e7eb;">
                                <div class="text-muted text-center py-4">暂无输出，请在画布上编排节点并启动工作流。</div>
                            </div>
                            <textarea id="finalResultBox" style="display:none;"></textarea>
                        </div>
                    </div>
                </div>

                <%-- ========== 右侧帮助面板 ========== --%>
                <div class="col-12 col-lg-3 order-lg-3">
                    <div class="card shadow-sm">
                        <div class="card-header bg-light">
                            <h3 class="card-title"><i class="ti ti-info-circle me-2 text-primary"></i> 操作指南</h3>
                        </div>
                        <div class="card-body" style="font-size:13px;">
                            <div class="mb-3">
                                <strong class="text-primary">1.</strong> 从<b>左侧面板点击</b>节点添加到画布
                            </div>
                            <div class="mb-3">
                                <strong class="text-primary">2.</strong> 节点自动<b>首尾拼接</b>成处理管道
                            </div>
                            <div class="mb-3">
                                <strong class="text-primary">3.</strong> <b>拖拽节点</b>到另一个节点上可交换顺序
                            </div>
                            <div class="mb-3">
                                <strong class="text-primary">4.</strong> 填入<b>初始任务内容</b>，点击「启动」
                            </div>
                            <div class="mb-3">
                                <strong class="text-primary">5.</strong> 执行完成后<b>点击节点</b>查看输出
                            </div>
                            <div class="text-muted">
                                <i class="ti ti-mouse me-1"></i> 滚轮缩放 · 拖拽空白平移
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<%-- ========== JavaScript 引擎 ========== --%>
<script>
// ==================== 全局状态 ====================
var nodeInstances = [];  // { id, nodeId, name, icon, el, x, y, outputData }
var pipelineConnectors = []; // DOM elements for connector arrows (var: 需要重新赋值)
var nodeIdCounter = 0;
// 管道布局参数
var NODE_WIDTH = 260;
var NODE_GAP = 16;        // 节点之间的间距（箭头放在中间）
var PIPELINE_START_X = 200;
var PIPELINE_START_Y = 200;
var ROW_BREAK_AFTER = 4;  // 每行最多 4 个节点后换行

var canvasPanX = 0, canvasPanY = 0;
var canvasZoom = 1;
var isPanning = false;
var isDraggingNode = false;
var panStart = { x: 0, y: 0 };
var dragTarget = null;
var dragOffset = { x: 0, y: 0 };
var executionAborted = false;

var CANVAS_WORLD_SIZE = 6000;

// ==================== 画布初始化 ====================
document.addEventListener('DOMContentLoaded', function() {
    const viewport = document.getElementById('canvasViewport');

    // 初始画布居中
    const vw = viewport.clientWidth;
    const vh = viewport.clientHeight;
    canvasPanX = (CANVAS_WORLD_SIZE - vw) / 2;
    canvasPanY = (CANVAS_WORLD_SIZE - vh) / 2;
    applyTransform();

    // --- 画布平移（空白区域拖拽） ---
    viewport.addEventListener('pointerdown', function(e) {
        const target = e.target;
        if (target.closest('.canvas-node') || target.closest('.zoom-controls') ||
            target.closest('button') || target.closest('select') || target.closest('input')) {
            return;
        }
        isPanning = true;
        panStart = { x: e.clientX - canvasPanX, y: e.clientY - canvasPanY };
        viewport.classList.add('panning');
        viewport.setPointerCapture(e.pointerId);
    });

    viewport.addEventListener('pointermove', function(e) {
        if (isPanning) {
            canvasPanX = e.clientX - panStart.x;
            canvasPanY = e.clientY - panStart.y;
            applyTransform();
        }
        if (isDraggingNode && dragTarget) {
            updateNodeDrag(e);
        }
    });

    viewport.addEventListener('pointerup', function(e) {
        if (isPanning) {
            isPanning = false;
            viewport.classList.remove('panning');
            viewport.releasePointerCapture(e.pointerId);
        }
        if (isDraggingNode && dragTarget) {
            endNodeDrag(e);
        }
    });

    viewport.addEventListener('pointerleave', function() {
        if (isPanning) {
            isPanning = false;
            viewport.classList.remove('panning');
        }
    });

    // --- 滚轮缩放 ---
    viewport.addEventListener('wheel', function(e) {
        e.preventDefault();
        const zoomFactor = e.deltaY < 0 ? 1.08 : 0.92;
        const newZoom = Math.min(2.5, Math.max(0.2, canvasZoom * zoomFactor));
        const rect = viewport.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        const worldX = (mouseX - canvasPanX) / canvasZoom;
        const worldY = (mouseY - canvasPanY) / canvasZoom;
        canvasPanX = mouseX - worldX * newZoom;
        canvasPanY = mouseY - worldY * newZoom;
        canvasZoom = newZoom;
        applyTransform();
        updateZoomLabel();
    }, { passive: false });

    // --- 触摸双指缩放 ---
    var lastPinchDist = 0;
    viewport.addEventListener('touchstart', function(e) {
        if (e.touches.length === 2) {
            lastPinchDist = Math.hypot(
                e.touches[0].clientX - e.touches[1].clientX,
                e.touches[0].clientY - e.touches[1].clientY
            );
        }
    });
    viewport.addEventListener('touchmove', function(e) {
        if (e.touches.length === 2) {
            e.preventDefault();
            var dist = Math.hypot(
                e.touches[0].clientX - e.touches[1].clientX,
                e.touches[0].clientY - e.touches[1].clientY
            );
            if (lastPinchDist > 0) {
                var factor = dist / lastPinchDist;
                var newZoom = Math.min(2.5, Math.max(0.2, canvasZoom * factor));
                canvasZoom = newZoom;
                applyTransform();
                updateZoomLabel();
            }
            lastPinchDist = dist;
        }
    }, { passive: false });

    // --- 侧边栏节点点击添加到画布 ---
    document.addEventListener('click', function(e) {
        var item = e.target.closest('.palette-item');
        if (!item || e.target.closest('input')) return;
        var nodeId = item.dataset.nodeId;
        var nodeName = item.dataset.nodeName;
        var nodeIcon = item.dataset.nodeIcon;
        if (nodeId && nodeName) {
            addNodeToCanvas(nodeId, nodeName, nodeIcon || 'ti ti-robot');
        }
    });

    restoreCanvasState();
    renderLocalSidebar();

    setTimeout(function() {
        var hint = document.getElementById('canvasHint');
        if (hint) hint.style.opacity = '0';
        setTimeout(function() { if (hint) hint.style.display = 'none'; }, 500);
    }, 8000);

    <c:if test="${not empty finalResult}">
        document.getElementById('finalResultBox').value = '${finalResult}';
        showFinalOutput();
        renderMarkdown();
        triggerConfetti();
    </c:if>

    <c:if test="${not empty autoTriggerPPT}">
        setTimeout(function() {
            executePPTNode(document.getElementById('autoTriggerPPTData').value);
        }, 800);
    </c:if>
});

// ==================== 变换应用 ====================
function applyTransform() {
    var world = document.getElementById('canvasWorld');
    world.style.transform = 'translate(' + canvasPanX + 'px, ' + canvasPanY + 'px) scale(' + canvasZoom + ')';
}

function updateZoomLabel() {
    document.getElementById('zoomLabel').textContent = Math.round(canvasZoom * 100) + '%';
}

// ==================== 管道布局引擎 ====================
function reflowPipeline() {
    var row = 0;
    var col = 0;

    // 先移除所有旧的连接箭头
    pipelineConnectors.forEach(function(c) { c.remove(); });
    pipelineConnectors = [];

    nodeInstances.forEach(function(inst, i) {
        // 计算行列
        row = Math.floor(i / ROW_BREAK_AFTER);
        col = i % ROW_BREAK_AFTER;

        var newX = PIPELINE_START_X + col * (NODE_WIDTH + NODE_GAP + 44);
        var newY = PIPELINE_START_Y + row * 320;

        // 平滑移动节点
        inst.el.style.transition = 'left 0.35s cubic-bezier(0.25, 0.46, 0.45, 0.94), top 0.35s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        inst.el.style.left = newX + 'px';
        inst.el.style.top = newY + 'px';
        inst.x = newX;
        inst.y = newY;

        // 更新步骤编号
        var badge = inst.el.querySelector('.node-step-badge');
        if (badge) badge.textContent = i + 1;

        // 在非行尾节点后面创建连接箭头
        if (col < ROW_BREAK_AFTER - 1 && i < nodeInstances.length - 1) {
            var nextRow = Math.floor((i + 1) / ROW_BREAK_AFTER);
            if (nextRow === row) {
                var arrow = createConnectorArrow(newX + NODE_WIDTH, newY);
                pipelineConnectors.push(arrow);
                document.getElementById('canvasWorld').appendChild(arrow);
            }
        }

        // 行尾 → 下一行行首：拐弯箭头
        if (col === ROW_BREAK_AFTER - 1 && i < nodeInstances.length - 1) {
            // 右下角到下一行左上角的拐弯
        }
    });

    // 清除 transition，避免后续拖拽卡顿
    setTimeout(function() {
        nodeInstances.forEach(function(inst) {
            inst.el.style.transition = 'box-shadow 0.2s, border-color 0.2s';
        });
    }, 400);
}

function createConnectorArrow(fromRight, nodeY) {
    var el = document.createElement('div');
    el.className = 'pipeline-connector';
    el.style.left = (fromRight + 2) + 'px';
    el.style.top = (nodeY + 70) + 'px'; // 垂直居中
    el.style.height = '2px';
    el.innerHTML = '<div class="connector-line"></div><i class="ti ti-chevron-right connector-arrow"></i>';
    return el;
}

// ==================== 节点操作 ====================
/**
 * 从侧边栏拖拽节点到画布指定位置
 */
function addNodeToCanvasAt(nodeId, nodeName, nodeIcon, worldX, worldY) {
    var world = document.getElementById('canvasWorld');

    var instance = createNodeInstance(nodeId, nodeName, nodeIcon, worldX - NODE_WIDTH / 2, worldY - 30);
    nodeInstances.push(instance);
    world.appendChild(instance.el);

    // 动画淡入
    instance.el.style.opacity = '0';
    instance.el.style.transform = 'scale(0.8)';
    requestAnimationFrame(function() {
        instance.el.style.transition = 'opacity 0.2s, transform 0.2s';
        instance.el.style.opacity = '1';
        instance.el.style.transform = 'scale(1)';
        setTimeout(function() {
            instance.el.style.transition = 'box-shadow 0.2s, border-color 0.2s';
        }, 200);
    });

    // 👑 重排管道布局，首次添加自动适应画布
    var isFirstNode = (nodeInstances.length === 1);
    reflowPipeline();
    if (isFirstNode) {
        setTimeout(resetView, 400); // 等 reflow 动画完成后再居中
    }

    var hint = document.getElementById('canvasHint');
    if (hint) { hint.style.opacity = '0'; setTimeout(function() { hint.style.display = 'none'; }, 300); }
}

/**
 * 点击添加到管道末尾（保留兼容）
 */
function addNodeToCanvas(nodeId, nodeName, nodeIcon) {
    // 默认添加到管道末尾附近
    var col = nodeInstances.length % ROW_BREAK_AFTER;
    var row = Math.floor(nodeInstances.length / ROW_BREAK_AFTER);
    var worldX = PIPELINE_START_X + col * (NODE_WIDTH + NODE_GAP + 44);
    var worldY = PIPELINE_START_Y + row * 320;
    addNodeToCanvasAt(nodeId, nodeName, nodeIcon, worldX + NODE_WIDTH / 2, worldY + 30);
}

function createNodeInstance(nodeId, nodeName, nodeIcon, x, y) {
    var id = 'node-' + (++nodeIdCounter);
    var index = nodeInstances.length;

    var el = document.createElement('div');
    el.className = 'canvas-node';
    el.id = id;
    el.style.left = x + 'px';
    el.style.top = y + 'px';
    el.dataset.nodeId = nodeId;
    el.dataset.nodeIndex = index;

    // 收集下拉框选项
    var templates = [];
    document.querySelectorAll('#paletteList .palette-item').forEach(function(item) {
        templates.push({ id: item.dataset.nodeId, name: item.dataset.nodeName, icon: item.dataset.nodeIcon });
    });
    templates.push({ id: '-1', name: '导出为 PowerPoint', icon: 'ti ti-file-powerpoint' });

    var optionsHtml = templates.map(function(t) {
        var sel = t.id === nodeId ? ' selected' : '';
        return '<option value="' + t.id + '"' + sel + '>' + t.name + '</option>';
    }).join('');

    el.innerHTML =
        '<div class="node-header" onpointerdown="startNodeDrag(event, \'' + id + '\')">' +
        '<span class="node-step-badge">' + (index + 1) + '</span>' +
        '<i class="node-icon ' + nodeIcon + '"></i>' +
        '<span class="node-title">' + escapeHtml(nodeName) + '</span>' +
        '<span class="node-status-dot" id="' + id + '-status"></span>' +
        '<button class="btn-close-node" onclick="removeNodeInstance(\'' + id + '\')" title="删除节点">×</button>' +
        '</div>' +
        '<div class="node-body">' +
        '<select class="node-type-select" id="' + id + '-select" onchange="onNodeTypeChange(\'' + id + '\')">' +
        optionsHtml +
        '</select>' +
        '<button class="btn-expand-output mt-2" id="' + id + '-expandBtn" style="display:none;" onclick="toggleNodeOutput(\'' + id + '\')">' +
        '<i class="ti ti-eye me-1"></i> 查看输出</button>' +
        '</div>' +
        '<div class="node-output-panel" id="' + id + '-outputPanel">' +
        '<div class="node-output-meta" id="' + id + '-meta"></div>' +
        '<div class="node-output-content" id="' + id + '-output"></div>' +
        '</div>';

    return { id: id, nodeId: nodeId, name: nodeName, icon: nodeIcon, el: el, x: x, y: y, outputData: null };
}

function removeNodeInstance(nodeElId) {
    var idx = nodeInstances.findIndex(function(n) { return n.id === nodeElId; });
    if (idx === -1) return;
    var inst = nodeInstances[idx];
    inst.el.style.opacity = '0';
    inst.el.style.transform = 'scale(0.8)';
    setTimeout(function() {
        inst.el.remove();
        nodeInstances.splice(idx, 1);
        if (nodeInstances.length > 0) {
            reflowPipeline();
        } else {
            pipelineConnectors.forEach(function(c) { c.remove(); });
            pipelineConnectors = [];
        }
    }, 200);
}

function onNodeTypeChange(nodeElId) {
    const inst = nodeInstances.find(function(n) { return n.id === nodeElId; });
    if (!inst) return;
    const select = document.getElementById(nodeElId + '-select');
    const newId = select.value;
    const newName = select.options[select.selectedIndex].text;
    inst.nodeId = newId;
    inst.name = newName;
    inst.el.querySelector('.node-title').textContent = newName;

    // 更新图标（从下拉框没法直接拿 icon，从 palette 查找）
    const paletteItem = document.querySelector('.palette-item[data-node-id="' + newId + '"]');
    if (paletteItem) {
        const iconClass = paletteItem.dataset.nodeIcon;
        inst.icon = iconClass;
        inst.el.querySelector('.node-icon').className = 'node-icon ' + iconClass;
    }

    // 清除旧的输出
    inst.outputData = null;
    inst.el.classList.remove('executing', 'done', 'error');
    var statusDot = document.getElementById(nodeElId + '-status');
    if (statusDot) statusDot.className = 'node-status-dot';
    var expandBtn = document.getElementById(nodeElId + '-expandBtn');
    if (expandBtn) expandBtn.style.display = 'none';
    var panel = document.getElementById(nodeElId + '-outputPanel');
    if (panel) panel.classList.remove('expanded');
}

function toggleNodeOutput(nodeElId) {
    const panel = document.getElementById(nodeElId + '-outputPanel');
    if (panel) panel.classList.toggle('expanded');
}

// ==================== 节点拖拽（用于调整排序） ====================
function startNodeDrag(e, nodeElId) {
    if (e.target.closest('select') || e.target.closest('button') ||
        e.target.closest('.node-output-panel')) {
        return;
    }
    e.preventDefault();
    e.stopPropagation();

    var inst = nodeInstances.find(function(n) { return n.id === nodeElId; });
    if (!inst) return;

    // 先清除所有节点的过渡动画
    nodeInstances.forEach(function(n) { n.el.style.transition = 'none'; });

    isDraggingNode = true;
    dragTarget = inst;

    var rect = inst.el.getBoundingClientRect();
    dragOffset = { x: e.clientX - rect.left, y: e.clientY - rect.top };

    inst.el.classList.add('dragging');
    inst.el.style.zIndex = '100';
    document.body.style.cursor = 'grabbing';
}

function updateNodeDrag(e) {
    if (!dragTarget) return;

    var viewport = document.getElementById('canvasViewport');
    var vpRect = viewport.getBoundingClientRect();

    var screenX = e.clientX - vpRect.left - dragOffset.x;
    var screenY = e.clientY - vpRect.top - dragOffset.y;
    var worldX = (screenX - canvasPanX) / canvasZoom;
    var worldY = (screenY - canvasPanY) / canvasZoom;

    dragTarget.x = worldX;
    dragTarget.y = worldY;
    dragTarget.el.style.left = worldX + 'px';
    dragTarget.el.style.top = worldY + 'px';

    // 检测是否悬停在其他节点上（交换位置）
    checkSwapTarget(e);
}

function endNodeDrag(e) {
    if (!dragTarget) return;
    dragTarget.el.classList.remove('dragging');
    dragTarget.el.style.zIndex = '10';

    // 检测是否需要交换位置
    var swapResult = performSwap();
    if (swapResult) {
        reflowPipeline();
    } else {
        // 没有交换，回到原位
        reflowPipeline();
    }

    isDraggingNode = false;
    dragTarget = null;
    document.body.style.cursor = '';
}

// 高亮交换目标
var swapHighlight = null;
function checkSwapTarget(e) {
    if (!dragTarget) return;

    // 清除旧高亮
    if (swapHighlight && swapHighlight !== dragTarget.el) {
        swapHighlight.style.borderColor = '';
        swapHighlight.style.boxShadow = '';
    }

    var draggedIdx = nodeInstances.indexOf(dragTarget);
    var targetIdx = -1;

    nodeInstances.forEach(function(inst, i) {
        if (inst === dragTarget) return;
        var rect = inst.el.getBoundingClientRect();
        if (e.clientX >= rect.left && e.clientX <= rect.right &&
            e.clientY >= rect.top && e.clientY <= rect.bottom) {
            targetIdx = i;
        }
    });

    if (targetIdx >= 0 && targetIdx !== draggedIdx) {
        swapHighlight = nodeInstances[targetIdx].el;
        swapHighlight.style.borderColor = '#206bc4';
        swapHighlight.style.boxShadow = '0 0 16px rgba(32,107,196,0.35)';
    } else {
        swapHighlight = null;
    }
}

function performSwap() {
    nodeInstances.forEach(function(inst) {
        inst.el.style.borderColor = '';
        inst.el.style.boxShadow = '';
    });

    if (!dragTarget || !swapHighlight) return false;

    var draggedIdx = nodeInstances.indexOf(dragTarget);
    // 从 DOM 找到目标的实例
    var targetInst = null;
    var targetIdx = -1;
    nodeInstances.forEach(function(inst, i) {
        if (inst.el === swapHighlight) { targetInst = inst; targetIdx = i; }
    });

    if (targetInst && targetIdx >= 0 && targetIdx !== draggedIdx) {
        // 交换数组中的位置
        var temp = nodeInstances[draggedIdx];
        nodeInstances[draggedIdx] = nodeInstances[targetIdx];
        nodeInstances[targetIdx] = temp;
        return true;
    }
    return false;
}


// ==================== 工作流执行 ====================
async function executeWorkflow() {
    if (nodeInstances.length === 0) {
        showToast('请先在画布上添加节点！', 'danger');
        return;
    }

    var userText = document.getElementById('userTextInput').value.trim();
    if (!userText) {
        showToast('请填写初始任务内容！', 'danger');
        return;
    }

    executionAborted = false;
    var btnExecute = document.getElementById('btnExecute');
    var btnStop = document.getElementById('btnStop');

    btnExecute.disabled = true;
    btnExecute.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> 执行中...';
    btnStop.style.display = '';

    // 重置所有节点状态
    nodeInstances.forEach(function(inst) {
        inst.el.classList.remove('executing', 'done', 'error');
        inst.outputData = null;
        var statusDot = document.getElementById(inst.id + '-status');
        if (statusDot) statusDot.className = 'node-status-dot';
        var expandBtn = document.getElementById(inst.id + '-expandBtn');
        if (expandBtn) expandBtn.style.display = 'none';
        var panel = document.getElementById(inst.id + '-outputPanel');
        if (panel) panel.classList.remove('expanded');
    });

    // 收集节点 ID 顺序
    var promptIds = nodeInstances.map(function(inst) { return inst.nodeId; });

    // 保存画板状态
    saveCanvasToStorage();

    try {
        var formData = new URLSearchParams();
        formData.append('userText', userText);
        formData.append('ajax', 'true');
        promptIds.forEach(function(pid) {
            formData.append('promptIds', pid);
        });

        var response = await fetch('chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: formData.toString()
        });

        if (!response.ok) {
            throw new Error('服务器返回状态码: ' + response.status);
        }

        var result = await response.json();
        processNodeResults(result);

    } catch (err) {
        console.error('执行失败:', err);
        showToast('执行失败: ' + err.message, 'danger');
        resetExecuteButton();
    }
}

function processNodeResults(result) {
    var nodeResults = result.nodeResults || [];
    var finalResult = result.finalResult || '';
    var pptData = result.autoTriggerPPT || '';

    // 模拟逐个节点完成的动画
    var delay = 0;
    nodeResults.forEach(function(nr, i) {
        delay += 400;
        setTimeout(function() {
            if (executionAborted) return;
            updateNodeWithResult(nr);
            // 如果是最后一个非 PPT 节点，显示最终输出
            if (i === nodeResults.length - 1) {
                showFinalResult(finalResult);
                resetExecuteButton();
                triggerConfetti();
            }
        }, delay);
    });

    // 处理 PPT 自动下载
    if (pptData) {
        setTimeout(function() {
            executePPTNode(pptData);
        }, delay + 800);
    }

    // 如果没有节点结果但有最终结果
    if (nodeResults.length === 0 && finalResult) {
        showFinalResult(finalResult);
        resetExecuteButton();
    }
}

function updateNodeWithResult(nodeResult) {
    var nodeIndex = nodeResult.nodeIndex;
    if (nodeIndex >= nodeInstances.length) return;

    var inst = nodeInstances[nodeIndex];
    var status = nodeResult.status;

    // 更新状态
    inst.el.classList.remove('executing');
    if (status === 'done') inst.el.classList.add('done');
    else if (status === 'error') inst.el.classList.add('error');

    var statusDot = document.getElementById(inst.id + '-status');
    if (statusDot) statusDot.className = 'node-status-dot ' + status;

    // 存储输出数据
    inst.outputData = nodeResult;

    // 显示输出面板
    var expandBtn = document.getElementById(inst.id + '-expandBtn');
    if (expandBtn) expandBtn.style.display = '';

    var meta = document.getElementById(inst.id + '-meta');
    if (meta) {
        meta.innerHTML =
            '<span><i class="ti ti-clock me-1"></i>' + (nodeResult.duration || 0) + 'ms</span>' +
            '<span><i class="ti ti-flame me-1"></i>' + (nodeResult.tokens || 0) + ' Token</span>' +
            '<span class="ms-auto"><i class="ti ti-' + (status === 'done' ? 'check text-success' : 'x text-danger') + '"></i></span>';
    }

    var output = document.getElementById(inst.id + '-output');
    if (output) {
        var outText = nodeResult.output || '';
        if (outText.length > 500) outText = outText.substring(0, 500) + '...(点击展开查看完整内容)';
        output.textContent = outText;
    }

    // 自动展开
    var panel = document.getElementById(inst.id + '-outputPanel');
    if (panel) panel.classList.add('expanded');
}

function showFinalResult(finalResult) {
    document.getElementById('finalResultBox').value = finalResult;
    showFinalOutput();
    renderMarkdown();
}

function showFinalOutput() {
    document.getElementById('finalOutputPanel').style.display = '';
}

function toggleFinalOutput() {
    var body = document.getElementById('finalOutputBody');
    var chevron = document.getElementById('finalOutputChevron');
    if (body.style.display === 'none') {
        body.style.display = '';
        chevron.style.transform = 'rotate(0deg)';
    } else {
        body.style.display = 'none';
        chevron.style.transform = 'rotate(-90deg)';
    }
}

function resetExecuteButton() {
    var btnExecute = document.getElementById('btnExecute');
    var btnStop = document.getElementById('btnStop');
    btnExecute.disabled = false;
    btnExecute.innerHTML = '<i class="ti ti-player-play me-2"></i> 启动自动化流转';
    btnStop.style.display = 'none';
}

function stopExecution() {
    executionAborted = true;
    resetExecuteButton();
    showToast('已停止执行');
}

// ==================== 最终结果渲染 ====================
function renderMarkdown() {
    var rawText = document.getElementById('finalResultBox').value;
    var viewer = document.getElementById('markdown-viewer');
    if (!rawText || !viewer) return;

    if (typeof marked !== 'undefined') {
        if (typeof hljs !== 'undefined') {
            marked.setOptions({
                highlight: function(code, lang) {
                    var language = hljs.getLanguage(lang) ? lang : 'plaintext';
                    return hljs.highlight(code, { language: language }).value;
                }
            });
        }
        viewer.innerHTML = marked.parse(rawText);
    } else {
        viewer.textContent = rawText;
    }
}

// ==================== PPT 导出 ====================
async function executePPTNode(aiGeneratedJsonString) {
    console.log('PPT 渲染节点启动...');
    var formData = new URLSearchParams();
    formData.append('action', 'export');
    formData.append('pptData', encodeURIComponent(aiGeneratedJsonString));

    try {
        var response = await fetch('pptServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: formData.toString()
        });
        if (!response.ok) throw new Error('渲染失败，状态码: ' + response.status);
        var blob = await response.blob();
        var downloadUrl = window.URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = downloadUrl;
        a.download = 'AI智能生成汇报.pptx';
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(downloadUrl);
        console.log('PPT 合成完毕并已触发下载！');
    } catch (error) {
        console.error('PPT 生成异常:', error);
        showToast('PPT 生成失败，请检查 AI 输出的 JSON 格式是否正确！', 'danger');
    }
}

// ==================== 缩放控制 ====================
function zoomIn() {
    canvasZoom = Math.min(2.5, canvasZoom * 1.2);
    var viewport = document.getElementById('canvasViewport');
    var vw = viewport.clientWidth;
    var vh = viewport.clientHeight;
    var worldCX = (vw / 2 - canvasPanX) / (canvasZoom / 1.2);
    var worldCY = (vh / 2 - canvasPanY) / (canvasZoom / 1.2);
    canvasPanX = vw / 2 - worldCX * canvasZoom;
    canvasPanY = vh / 2 - worldCY * canvasZoom;
    applyTransform();
    updateZoomLabel();
}

function zoomOut() {
    canvasZoom = Math.max(0.2, canvasZoom * 0.833);
    var viewport = document.getElementById('canvasViewport');
    var vw = viewport.clientWidth;
    var vh = viewport.clientHeight;
    var worldCX = (vw / 2 - canvasPanX) / (canvasZoom / 0.833);
    var worldCY = (vh / 2 - canvasPanY) / (canvasZoom / 0.833);
    canvasPanX = vw / 2 - worldCX * canvasZoom;
    canvasPanY = vh / 2 - worldCY * canvasZoom;
    applyTransform();
    updateZoomLabel();
}

function resetView() {
    canvasZoom = 1;
    var viewport = document.getElementById('canvasViewport');
    var vw = viewport.clientWidth;
    var vh = viewport.clientHeight;
    canvasPanX = (CANVAS_WORLD_SIZE - vw) / 2;
    canvasPanY = (CANVAS_WORLD_SIZE - vh) / 2;

    // 如果已有节点，居中显示管道
    if (nodeInstances.length > 0) {
        var minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
        nodeInstances.forEach(function(inst) {
            minX = Math.min(minX, inst.x);
            minY = Math.min(minY, inst.y);
            maxX = Math.max(maxX, inst.x + NODE_WIDTH + NODE_GAP + 44);
            maxY = Math.max(maxY, inst.y + 250);
        });
        var nodesW = maxX - minX + 120;
        var nodesH = maxY - minY + 120;
        var fitZoom = Math.min(vw / nodesW, vh / nodesH, 1.2);
        canvasZoom = Math.max(0.3, fitZoom);
        canvasPanX = vw / 2 - (minX + nodesW / 2) * canvasZoom;
        canvasPanY = vh / 2 - (minY + nodesH / 2) * canvasZoom;
    }

    applyTransform();
    updateZoomLabel();
}

// ==================== 画板清空 ====================
function clearCanvas() {
    tablerConfirm('清空画板', '确定要清空画板上的所有节点吗？此操作不可撤销。', function() {
        while (nodeInstances.length > 0) {
            var inst = nodeInstances.pop();
            inst.el.remove();
        }
        pipelineConnectors.forEach(function(c) { c.remove(); });
        pipelineConnectors = [];
        document.getElementById('finalResultBox').value = '';
        var viewer = document.getElementById('markdown-viewer');
        if (viewer) viewer.innerHTML = '<div class="text-muted text-center py-4">暂无输出，请在画布上编排节点并启动工作流。</div>';
        document.getElementById('finalOutputPanel').style.display = 'none';
        showToast('画板已清空');
    });
}

// ==================== 序列化与缓存 ====================
function getCanvasJson() {
    var nodes = nodeInstances.map(function(inst) {
        return {
            nodeId: inst.nodeId,
            name: inst.name,
            icon: inst.icon,
            x: inst.x,
            y: inst.y
        };
    });
    return {
        nodes: nodes,
        input: document.getElementById('userTextInput').value,
        panX: canvasPanX,
        panY: canvasPanY,
        zoom: canvasZoom
    };
}

function renderCanvas(jsonObj) {
    if (!jsonObj) return;

    // 清空画布（节点 + 连接箭头）
    while (nodeInstances.length > 0) {
        var old = nodeInstances.pop();
        old.el.remove();
    }
    pipelineConnectors.forEach(function(c) { c.remove(); });
    pipelineConnectors = [];

    // 恢复输入
    if (jsonObj.input !== undefined) {
        document.getElementById('userTextInput').value = jsonObj.input;
    }

    // 恢复视图
    if (jsonObj.panX !== undefined) canvasPanX = jsonObj.panX;
    if (jsonObj.panY !== undefined) canvasPanY = jsonObj.panY;
    if (jsonObj.zoom !== undefined) canvasZoom = jsonObj.zoom;

    // 恢复节点
    if (jsonObj.nodes && Array.isArray(jsonObj.nodes)) {
        var world = document.getElementById('canvasWorld');
        jsonObj.nodes.forEach(function(n) {
            var inst = createNodeInstance(
                n.nodeId || '-1',
                n.name || '未命名',
                n.icon || 'ti ti-robot',
                n.x || 200 + nodeInstances.length * 50,
                n.y || 200 + nodeInstances.length * 50
            );
            nodeInstances.push(inst);
            world.appendChild(inst.el);
        });
    }

    applyTransform();
    updateZoomLabel();
    reflowPipeline();
}

function saveCanvasToStorage() {
    try {
        sessionStorage.setItem('ai_workflow_canvas_state', JSON.stringify(getCanvasJson()));
    } catch(e) { /* quota exceeded, ignore */ }
}

function restoreCanvasState() {
    try {
        var saved = sessionStorage.getItem('ai_workflow_canvas_state');
        if (saved) {
            var jsonObj = JSON.parse(saved);
            // 只在没有服务器数据时恢复
            <c:if test="${empty finalResult}">
                renderCanvas(jsonObj);
            </c:if>
        }
    } catch(e) { /* ignore */ }
}

// ==================== 本地缓存功能（保留原有逻辑） ====================
var CACHE_KEY = 'ai_workflow_local_history';

function saveToLocalCache() {
    var name = prompt('给这个暂存的工作流起个名字吧：', '未命名工作流 ' + new Date().toLocaleTimeString());
    if (!name) return;

    var record = {
        id: Date.now(),
        name: name,
        timestamp: new Date().toLocaleString(),
        data: getCanvasJson()
    };

    var history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
    history.unshift(record);
    if (history.length > 20) history.pop();
    localStorage.setItem(CACHE_KEY, JSON.stringify(history));
    renderLocalSidebar();
    showToast('已秒存至浏览器本地缓存！');
}

function renderLocalSidebar() {
    var history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
    var container = document.getElementById('localWorkflowList');
    if (!container) return;

    if (history.length === 0) {
        container.innerHTML = '<div class="p-3 text-center text-muted" style="font-size:12px;">暂无本地缓存</div>';
        return;
    }

    container.innerHTML = history.map(function(item) {
        return '<div class="list-group-item list-group-item-action d-flex align-items-center">' +
            '<div class="flex-fill" style="cursor:pointer;" onclick="loadFromCache(' + item.id + ')">' +
            '<div class="fw-bold text-dark" style="font-size:13px;"><i class="ti ti-file-code me-2 text-muted"></i>' + escapeHtml(item.name) + '</div>' +
            '<div class="text-muted" style="font-size:11px; margin-left:24px;">' + item.timestamp + '</div>' +
            '</div>' +
            '<a href="#" class="text-danger ms-auto p-2" onclick="deleteCache(' + item.id + ')" title="删除">' +
            '<i class="ti ti-trash"></i></a>' +
            '</div>';
    }).join('');
}

function loadFromCache(id) {
    tablerConfirm('覆盖画板警告', '加载工作流将覆盖当前画板上的所有未保存内容，确定加载吗？', function() {
        var history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
        var record = history.find(function(item) { return item.id === id; });
        if (record) {
            renderCanvas(record.data);
            showToast('成功恢复：' + record.name);
        }
    });
}

function deleteCache(id) {
    tablerConfirm('彻底删除', '确定要删除这条本地暂存记录吗？', function() {
        var history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
        var filtered = history.filter(function(item) { return item.id !== id; });
        localStorage.setItem(CACHE_KEY, JSON.stringify(filtered));
        renderLocalSidebar();
    });
}

function exportToFile() {
    var canvasData = getCanvasJson();
    var jsonStr = JSON.stringify(canvasData, null, 2);
    var blob = new Blob([jsonStr], { type: 'application/json' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = 'workflow_' + new Date().getTime() + '.json';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    showToast('导出成功！');
}

function importFromFile(event) {
    var file = event.target.files[0];
    if (!file) return;
    var reader = new FileReader();
    reader.onload = function(e) {
        try {
            var jsonObj = JSON.parse(e.target.result);
            renderCanvas(jsonObj);
            showToast('文件导入并解析成功！');
        } catch (err) {
            showToast('导入失败，不是合法的 JSON 工作流文件！', 'danger');
        }
        event.target.value = '';
    };
    reader.readAsText(file);
}

// ==================== 节点面板搜索 ====================
function filterPalette() {
    var keyword = (document.getElementById('paletteSearch').value || '').toLowerCase();
    document.querySelectorAll('#paletteList .palette-item').forEach(function(item) {
        var text = (item.dataset.nodeName + ' ' + item.dataset.nodeDesc).toLowerCase();
        item.style.display = text.includes(keyword) ? '' : 'none';
    });
}

// ==================== 工具函数 ====================
function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function triggerConfetti() {
    if (typeof confetti === 'undefined') return;
    var duration = 3 * 1000;
    var animationEnd = Date.now() + duration;
    var defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 9999 };

    function randomInRange(min, max) { return Math.random() * (max - min) + min; }

    var interval = setInterval(function() {
        var timeLeft = animationEnd - Date.now();
        if (timeLeft <= 0) return clearInterval(interval);
        var particleCount = 50 * (timeLeft / duration);
        confetti(Object.assign({}, defaults, {
            particleCount: particleCount,
            origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 },
            colors: ['#26eb26', '#206bc4', '#f59f00', '#d63939', '#74b816']
        }));
        confetti(Object.assign({}, defaults, {
            particleCount: particleCount,
            origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 },
            colors: ['#26eb26', '#206bc4', '#f59f00', '#d63939', '#74b816']
        }));
    }, 250);
}
</script>

<%-- 隐藏的 PPT 数据区 --%>
<c:if test="${not empty autoTriggerPPT}">
    <textarea id="autoTriggerPPTData" style="display:none;"><c:out value="${autoTriggerPPT}" /></textarea>
</c:if>

<%-- CDN 库 --%>
<script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-dark.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>

<jsp:include page="footer.jsp" />
