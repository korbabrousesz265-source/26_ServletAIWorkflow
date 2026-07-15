<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    /* ========== 画板容器 ========== */
    .canvas-viewport {
        position: relative;
        width: 100%;
        /* 👑 改为 75vh 或更高，让画板霸占屏幕 */
        height: 75vh;
        min-height: 600px;
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
    /* 👑 ComfyUI 风格右键菜单 */
    .comfy-context-menu {
        position: fixed;
        width: 240px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(0,0,0,0.1);
        box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        border-radius: 8px;
        z-index: 9999;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        transform-origin: top left;
        animation: menuFadeIn 0.15s ease-out;
    }
    @keyframes menuFadeIn {
        from { opacity: 0; transform: scale(0.95); }
        to { opacity: 1; transform: scale(1); }
    }
    .comfy-context-search {
        padding: 8px;
        border-bottom: 1px solid #e5e7eb;
    }
    .comfy-context-search input {
        width: 100%;
        padding: 6px 10px;
        background: #f8f9fa;
        border: 1px solid #dce1e7;
        border-radius: 4px;
        font-size: 12px;
        outline: none;
    }
    .comfy-context-search input:focus { border-color: #206bc4; }
    .comfy-context-list {
        max-height: 250px;
        overflow-y: auto;
        padding: 4px;
    }
    .comfy-context-item {
        padding: 8px 10px;
        border-radius: 4px;
        font-size: 13px;
        color: #1e293b;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .comfy-context-item:hover { background: #206bc4; color: #fff; }
    .comfy-context-item:hover .ti { color: #fff !important; }
    /* 👑 沉浸式无边界画板 */
    .canvas-viewport {
        position: relative;
        width: 100%;
        /* 霸占除了顶部导航栏之外的所有屏幕空间 */
        height: calc(100vh - 60px);
        min-height: 600px;
        overflow: hidden;
        background: #f0f2f5; /* 更柔和的极客灰底色 */
        border: none;
        border-radius: 0;
        cursor: grab;
        user-select: none;
        -webkit-user-select: none;
    }

    /* 👑 悬浮毛玻璃输入舱 (拓宽版) */
    .floating-input-panel {
        position: absolute;
        top: 24px;
        left: 24px;
        width: 420px; /* 🚀 从 340px 拓宽到 420px，大气舒展 */
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(16px);
        -webkit-backdrop-filter: blur(16px);
        border: 1px solid rgba(255, 255, 255, 0.5);
        border-radius: 16px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.08);
        z-index: 40;
        padding: 24px; /* 增加内边距 */
        transition: transform 0.3s ease;
    }
    .floating-input-panel:hover {
        transform: translateY(-2px);
        box-shadow: 0 15px 50px rgba(0,0,0,0.12);
    }

    /* 👑 输入框本体完全自适应填充 */
    .floating-input-panel textarea {
        width: 100%;           /* 🚀 强制铺满舱体宽度 */
        min-height: 160px;     /* 🚀 增加默认高度，方便录入长文本 */
        padding: 14px;         /* 🚀 舒服的文字内边距 */
        box-sizing: border-box;
        resize: vertical;      /* 允许用户按需上下拉伸 */
        background: rgba(255, 255, 255, 0.7);
        border: 1px solid rgba(0,0,0,0.1);
        border-radius: 10px;
        font-size: 14px;
        line-height: 1.6;
        color: #1e293b;
        transition: all 0.2s;
    }
    .floating-input-panel textarea:focus {
        background: #fff;
        outline: none;
        border-color: #206bc4;
        box-shadow: 0 0 0 3px rgba(32, 107, 196, 0.15);
    }

    /* 👑 底部中央的悬浮控制台 (代替原本在下方的按钮) */
    .floating-action-bar {
        position: absolute;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 40;
        display: flex;
        align-items: center;
        gap: 12px;
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(20px);
        padding: 8px 12px;
        border-radius: 100px;
        box-shadow: 0 12px 36px rgba(0,0,0,0.12);
        border: 1px solid rgba(255,255,255,0.8);
    }
    .floating-action-bar .btn {
        border-radius: 100px;
        padding: 10px 24px;
        font-weight: bold;
        letter-spacing: 0.5px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    }
    .floating-action-bar .btn-primary { background: #206bc4; border: none; }
    .floating-action-bar .btn-primary:hover { background: #1a569d; transform: scale(1.02); }

    /* 👑 节点左右侧的输入输出端口 (Anchors) */
    .port {
        width: 14px; height: 14px;
        border-radius: 50%;
        background: #ffffff;
        border: 3px solid #206bc4;
        position: absolute;
        top: 50%; transform: translateY(-50%);
        cursor: crosshair;
        z-index: 1000; /* 🚀 调高层级，确保不被节点内容遮挡 */
        transition: transform 0.2s, background 0.2s;
        touch-action: none; /* 🚀 阻止移动端的默认滚动/缩放行为干扰连线 */
    }
    .port:hover { transform: translateY(-50%) scale(1.3); background: #206bc4; }
    .port-in { left: -7px; }
    .port-out { right: -7px; }

    /* 👑 新增：真正的 SVG 贝塞尔曲线层 */
    #wireLayer {
        position: absolute; top: 0; left: 0;
        width: 100%; height: 100%;
        pointer-events: none; /* 让鼠标事件穿透 svg 从而能拖拽节点 */
        z-index: 5;
    }
    .wire-path {
        fill: none;
        stroke: #206bc4;
        stroke-width: 3px;
        stroke-linecap: round;
        opacity: 0.6;
        transition: stroke 0.3s, stroke-width 0.3s;
    }
    .wire-path:hover { opacity: 1; stroke: #f59f00; stroke-width: 5px; pointer-events: auto; cursor: pointer; }

    /* 隐藏旧版的生硬箭头 */
    .pipeline-connector { display: none !important; }
    .canvas-node.source-node { border-color: #1e293b; box-shadow: 0 4px 16px rgba(0,0,0,0.1); width: 300px; }
    .canvas-node.source-node .form-control:focus { box-shadow: none; border-color: #1e293b; }
</style>

<!-- 👑 潜伏的右键菜单 DOM (彻底纯动态渲染) -->
<div id="comfyContextMenu" class="comfy-context-menu" style="display: none;">
    <div class="comfy-context-search">
        <input type="text" id="contextSearchInput" placeholder="搜索节点 (Search...)">
    </div>
    <div class="comfy-context-list" id="contextMenuList">

        <!-- 所有的节点（包括 AI 节点和 ID为负数的工具节点）都由数据库统一吐出 -->
        <c:forEach var="tpl" items="${templates}">
            <div class="comfy-context-item" data-id="${tpl.id}" data-name="${tpl.name}" data-icon="${tpl.icon}">
                <!-- 针对插件节点给予不同的颜色区分 -->
                <i class="ti ${tpl.icon} ${tpl.id < 0 ? 'text-warning fw-bold' : 'text-primary'}"></i> ${tpl.name}
            </div>
        </c:forEach>


        <!-- ================= 增加自定义多源输入节点 ================= -->
        <div class="comfy-context-item" style="border-top: 1px solid #eee; margin-top: 4px;" data-id="-3" data-name="自定义独立文本输入" data-icon="ti ti-forms">
            <i class="ti ti-forms text-success"></i> 自定义独立文本输入
        </div>
    </div>
</div>

<div class="page-wrapper">
    <%-- 🔑 悬浮 API Key 警告 (绝对定位在顶部正中) --%>
    <c:if test="${showApiKeyWarning}">
        <div class="position-absolute top-0 start-50 translate-middle-x mt-3 w-50" style="z-index: 1000;">
            <!-- 👑 修复：强制白底 (bg-white)，加粗橙色左边框，彻底解决透色问题 -->
            <div class="alert shadow-lg border-0 rounded-4 bg-white" role="alert" style="border-left: 6px solid #f59f00;">
                <div class="d-flex align-items-center">
                    <div class="me-3"><i class="ti ti-alert-triangle fs-2 text-warning"></i></div>
                    <div class="flex-fill text-dark fw-bold">尚未配置 API 密钥，将使用系统公共算力。</div>
                    <a href="profile?action=index" class="btn btn-warning btn-sm fw-bold rounded-pill shadow-sm">前往配置</a>
                    <a class="btn-close ms-3" data-bs-dismiss="alert" aria-label="close"></a>
                </div>
            </div>
        </div>
    </c:if>

    <%-- 👑 无边界沉浸式画布 --%>
    <div class="canvas-viewport" id="canvasViewport">



        <!-- 2. 悬浮右上角：工具箱唤醒球 -->
        <button class="btn btn-dark btn-icon rounded-circle position-absolute bottom-0 start-0 m-4 shadow-lg" style="z-index: 50; width: 54px; height: 54px;" data-bs-toggle="offcanvas" data-bs-target="#toolboxOffcanvas" title="打开工具箱">
            <i class="ti ti-box fs-2"></i>
        </button>

        <!-- 3. 悬浮底边中：执行引擎飞船 -->
        <div class="floating-action-bar">
            <button class="btn btn-primary" id="btnExecute" onclick="executeWorkflow()">
                <i class="ti ti-player-play me-2"></i> 启动引擎 (Run)
            </button>
            <button class="btn btn-danger" onclick="stopExecution()" id="btnStop" style="display:none;">
                <i class="ti ti-square-rounded me-2"></i> 紧急停机
            </button>
            <div style="width: 1px; height: 24px; background: #dee2e6; margin: 0 4px;"></div>
            <!-- 呼出底部终端的按钮 -->
            <button class="btn btn-light text-dark" data-bs-toggle="offcanvas" data-bs-target="#outputOffcanvas">
                <i class="ti ti-layout-bottombar text-primary me-2"></i> 终端输出
            </button>
        </div>

        <!-- 底层画板世界 -->
        <div class="canvas-world" id="canvasWorld">
            <div class="canvas-grid"></div>
        </div>

        <!-- 缩放控件也改成极简风格 -->
        <div class="zoom-controls">
            <button onclick="zoomIn()" title="放大">+</button>
            <div class="zoom-label" id="zoomLabel">100%</div>
            <button onclick="zoomOut()" title="缩小">−</button>
            <button onclick="resetView()" title="适应画布" style="font-size:14px;">⊞</button>
        </div>
    </div>
</div>

<!-- 👑 动态底部抽屉 (代替原本在下方的输出结果面板) -->
<div class="offcanvas offcanvas-bottom" tabindex="-1" id="outputOffcanvas" style="height: 55vh; border-radius: 24px 24px 0 0; box-shadow: 0 -10px 40px rgba(0,0,0,0.1);">
    <div class="offcanvas-header bg-dark text-white" style="border-radius: 24px 24px 0 0;">
        <h3 class="offcanvas-title fw-bold"><i class="ti ti-terminal-2 text-green me-2"></i> Execution Output 终端输出</h3>
        <span class="ms-4 text-muted fs-5" id="outputMeta"></span>
        <button type="button" class="btn-close btn-close-white text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body bg-light p-4">
        <div id="markdown-viewer" class="bg-white p-4 rounded-3 shadow-sm" style="min-height: 100%; overflow-y: auto; font-size: 15px; border: 1px solid #e5e7eb;">
            <div class="text-muted text-center py-5 d-flex flex-column align-items-center">
                <i class="ti ti-code-dots text-gray-300 mb-3" style="font-size: 4rem;"></i>
                暂无输出数据，请在上方编排节点并启动流转。
            </div>
        </div>
        <textarea id="finalResultBox" style="display:none;"></textarea>
    </div>
</div>

<%-- ========== JavaScript 引擎 ========== --%>
<script>
    // ==================== 全局核心状态 ====================
    var nodeInstances = [];
    var edges = [];
    var nodeIdCounter = 0;
    var canvasPanX = 0, canvasPanY = 0, canvasZoom = 1;
    var isPanning = false, isDraggingNode = false, isDrawingWire = false;
    var panStart = { x: 0, y: 0 }, dragOffset = { x: 0, y: 0 };
    var dragTarget = null, tempWireStartPort = null, executionAborted = false;
    var CANVAS_WORLD_SIZE = 6000;

    // ==================== 1. 初始化与事件总线 ====================
    document.addEventListener('DOMContentLoaded', function() {
        const viewport = document.getElementById('canvasViewport');
        const world = document.getElementById('canvasWorld');

        canvasPanX = (CANVAS_WORLD_SIZE - viewport.clientWidth) / 2;
        canvasPanY = (CANVAS_WORLD_SIZE - viewport.clientHeight) / 2;
        applyTransform();

        world.insertAdjacentHTML('beforeend', '<svg id="wireLayer"><path id="tempWire" class="wire-path" style="display:none;"/></svg>');

        addNodeToCanvasAt('-999', '全局初始任务', 'ti ti-terminal-2', 100 + 260/2, 100 + 30);

        viewport.addEventListener('pointerdown', handlePointerDown);
        document.addEventListener('pointermove', handlePointerMove);
        document.addEventListener('pointerup', handlePointerUp);
        viewport.addEventListener('wheel', handleWheel, { passive: false });

        initContextMenu();
        restoreCanvasState();
        renderLocalSidebar();

        setTimeout(function() {
            let hint = document.getElementById('canvasHint');
            if (hint) hint.style.display = 'none';
        }, 5000);
    });

    function applyTransform() {
        document.getElementById('canvasWorld').style.transform = 'translate(' + canvasPanX + 'px, ' + canvasPanY + 'px) scale(' + canvasZoom + ')';
        document.getElementById('zoomLabel').textContent = Math.round(canvasZoom * 100) + '%';
    }

    function handlePointerDown(e) {
        if (e.target.closest('.canvas-node') || e.target.closest('.zoom-controls') || e.target.closest('button') || e.target.closest('.port')) return;
        isPanning = true;
        panStart = { x: e.clientX - canvasPanX, y: e.clientY - canvasPanY };
        document.getElementById('canvasViewport').classList.add('panning');
    }

    function handlePointerMove(e) {
        if (isPanning) {
            canvasPanX = e.clientX - panStart.x;
            canvasPanY = e.clientY - panStart.y;
            applyTransform();
        }
        if (isDraggingNode && dragTarget) {
            let vpRect = document.getElementById('canvasViewport').getBoundingClientRect();
            let wX = (e.clientX - vpRect.left - dragOffset.x - canvasPanX) / canvasZoom;
            let wY = (e.clientY - vpRect.top - dragOffset.y - canvasPanY) / canvasZoom;
            dragTarget.x = wX; dragTarget.y = wY;
            dragTarget.el.style.left = wX + 'px'; dragTarget.el.style.top = wY + 'px';
            renderWires();
        }
        if (isDrawingWire && tempWireStartPort) {
            let vpRect = document.getElementById('canvasViewport').getBoundingClientRect();
            let startRect = tempWireStartPort.getBoundingClientRect();
            let sX = (startRect.left + 7 - vpRect.left - canvasPanX) / canvasZoom;
            let sY = (startRect.top + 7 - vpRect.top - canvasPanY) / canvasZoom;
            let eX = (e.clientX - vpRect.left - canvasPanX) / canvasZoom;
            let eY = (e.clientY - vpRect.top - canvasPanY) / canvasZoom;
            document.getElementById('tempWire').setAttribute("d", 'M ' + sX + ' ' + sY + ' C ' + (sX+100) + ' ' + sY + ', ' + (eX-100) + ' ' + eY + ', ' + eX + ' ' + eY);
        }
    }

    function handlePointerUp(e) {
        if (isPanning) {
            isPanning = false;
            document.getElementById('canvasViewport').classList.remove('panning');
        }
        if (isDraggingNode) {
            dragTarget.el.classList.remove('dragging');
            isDraggingNode = false; dragTarget = null;
            renderWires();
        }
        if (isDrawingWire) {
            isDrawingWire = false;
            document.getElementById('tempWire').style.display = 'none';
            let targetEl = document.elementFromPoint(e.clientX, e.clientY);
            if (targetEl && targetEl.classList.contains('port-in')) {
                let targetId = targetEl.closest('.canvas-node').id;
                let sourceId = tempWireStartPort.closest('.canvas-node').id;
                let edgeExists = edges.some(function(edge) { return edge.from === sourceId && edge.to === targetId; });
                if (targetId !== sourceId && !edgeExists) {
                    edges.push({ from: sourceId, to: targetId });
                    renderWires();
                }
            }
            tempWireStartPort = null;
        }
    }

    function handleWheel(e) {
        e.preventDefault();
        const zF = e.deltaY < 0 ? 1.08 : 0.92;
        const nZ = Math.min(2.5, Math.max(0.2, canvasZoom * zF));
        const vpRect = document.getElementById('canvasViewport').getBoundingClientRect();
        const mX = e.clientX - vpRect.left, mY = e.clientY - vpRect.top;
        canvasPanX = mX - ((mX - canvasPanX) / canvasZoom) * nZ;
        canvasPanY = mY - ((mY - canvasPanY) / canvasZoom) * nZ;
        canvasZoom = nZ;
        applyTransform();
    }

    // ==================== 2. 右键菜单与交互 ====================
    function initContextMenu() {
        const vp = document.getElementById('canvasViewport');
        const menu = document.getElementById('comfyContextMenu');
        const searchInput = document.getElementById('contextSearchInput');

        vp.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            window.contextWorldX = (e.clientX - vp.getBoundingClientRect().left - canvasPanX) / canvasZoom;
            window.contextWorldY = (e.clientY - vp.getBoundingClientRect().top - canvasPanY) / canvasZoom;
            menu.style.left = e.clientX + 'px';
            menu.style.top = e.clientY + 'px';
            menu.style.display = 'flex';
            setTimeout(function() { searchInput.focus(); }, 50);
        });

        document.addEventListener('click', function(e) {
            if (!menu.contains(e.target)) menu.style.display = 'none';
        });

        searchInput.addEventListener('input', function(e) {
            let kw = e.target.value.toLowerCase().trim();
            document.querySelectorAll('.comfy-context-item').forEach(function(item) {
                item.style.display = item.dataset.name.toLowerCase().includes(kw) ? 'flex' : 'none';
            });
        });

        document.querySelectorAll('.comfy-context-item').forEach(function(item) {
            item.addEventListener('click', function() {
                addNodeToCanvasAt(this.dataset.id, this.dataset.name, this.dataset.icon, window.contextWorldX, window.contextWorldY);
                menu.style.display = 'none';
            });
        });
    }

    // ==================== 3. 连线引擎 ====================
    function startWire(e, nodeId) {
        e.preventDefault(); e.stopPropagation();
        isDrawingWire = true;
        tempWireStartPort = document.getElementById(nodeId).querySelector('.port-out');
        document.getElementById('tempWire').style.display = '';
    }

    function renderWires() {
        var svg = document.getElementById('wireLayer');
        svg.querySelectorAll('.solid-wire').forEach(function(e) { e.remove(); });
        var wR = document.getElementById('canvasWorld').getBoundingClientRect();

        edges.forEach(function(edge, index) {
            var n1 = document.getElementById(edge.from), n2 = document.getElementById(edge.to);
            if(!n1 || !n2) return;
            var pO = n1.querySelector('.port-out'), pI = n2.querySelector('.port-in');
            if(!pO || !pI) return;

            var r1 = pO.getBoundingClientRect(), r2 = pI.getBoundingClientRect();
            var sX = (r1.left + 7 - wR.left) / canvasZoom, sY = (r1.top + 7 - wR.top) / canvasZoom;
            var eX = (r2.left + 7 - wR.left) / canvasZoom, eY = (r2.top + 7 - wR.top) / canvasZoom;

            var path = document.createElementNS("http://www.w3.org/2000/svg", "path");
            path.setAttribute("d", 'M ' + sX + ' ' + sY + ' C ' + (sX+100) + ' ' + sY + ', ' + (eX-100) + ' ' + eY + ', ' + eX + ' ' + eY);
            path.setAttribute("class", "wire-path solid-wire");
            path.ondblclick = function(e) { e.stopPropagation(); edges.splice(index, 1); renderWires(); };
            svg.appendChild(path);
        });
    }

    // ==================== 4. 节点构建引擎 ====================
    function createNodeInstance(nodeId, nodeName, nodeIcon, x, y, forceDomId) {
        var id = forceDomId ? forceDomId : 'node-' + (++nodeIdCounter);
        var el = document.createElement('div');
        el.className = 'canvas-node' + ((nodeId === '-999' || nodeId === '-3') ? ' source-node' : '');
        el.id = id; el.style.left = x + 'px'; el.style.top = y + 'px';
        el.dataset.nodeId = nodeId; el.dataset.nodeIndex = nodeInstances.length;

        var portInHtml = (nodeId === '-999' || nodeId === '-3') ? '' : '<div class="port port-in"></div>';
        var bodyHtml = '';

        if (nodeId === '-999' || nodeId === '-3') {
            var placeholder = nodeId === '-999' ? '全局初始任务（起点）...' : '独立的数据源输入...';
            bodyHtml = '<textarea class="form-control node-input-text" rows="4" style="font-size:12px; resize:none;" placeholder="' + placeholder + '"></textarea>';
        } else {
            var templates = [];
            document.querySelectorAll('#contextMenuList .comfy-context-item').forEach(function(item) {
                templates.push({ id: item.dataset.id, name: item.dataset.name });
            });
            var optionsHtml = templates.map(function(t) {
                return '<option value="' + t.id + '" ' + (t.id === nodeId ? 'selected' : '') + '>' + t.name + '</option>';
            }).join('');
            bodyHtml = '<select class="node-type-select" id="' + id + '-select" onchange="onNodeTypeChange(\'' + id + '\')">' + optionsHtml + '</select>' +
                '<button class="btn-expand-output mt-2 w-100" id="' + id + '-expandBtn" style="display:none;" onclick="document.getElementById(\'' + id + '-outputPanel\').classList.toggle(\'expanded\')"><i class="ti ti-eye me-1"></i> 查看输出</button>';
        }

        el.innerHTML = portInHtml +
            '<div class="node-header" onpointerdown="startNodeDrag(event, \'' + id + '\')">' +
            '<i class="node-icon ' + nodeIcon + '"></i><span class="node-title" style="cursor: move;">' + escapeHtml(nodeName) + '</span>' +
            '<span class="node-status-dot" id="' + id + '-status"></span>' +
            '<button class="btn-close-node" onclick="removeNodeInstance(\'' + id + '\')">×</button>' +
            '</div>' +
            '<div class="node-body p-2">' + bodyHtml + '</div>' +
            '<div class="node-output-panel" id="' + id + '-outputPanel">' +
            '<div class="node-output-meta" id="' + id + '-meta"></div><div class="node-output-content" id="' + id + '-output"></div>' +
            '</div>' +
            '<div class="port port-out" onpointerdown="startWire(event, \'' + id + '\')"></div>';

        return { id: id, nodeId: nodeId, name: nodeName, icon: nodeIcon, el: el, x: x, y: y, outputData: null };
    }

    function addNodeToCanvasAt(id, name, icon, x, y) {
        var inst = createNodeInstance(id, name, icon, x, y, null);
        nodeInstances.push(inst);
        document.getElementById('canvasWorld').appendChild(inst.el);
        updateMonitor();
    }

    function removeNodeInstance(id) {
        let idx = nodeInstances.findIndex(function(n) { return n.id === id; });
        if(idx !== -1) {
            nodeInstances[idx].el.remove(); nodeInstances.splice(idx, 1);
            edges = edges.filter(function(e) { return e.from !== id && e.to !== id; });
            renderWires(); updateMonitor();
        }
    }

    function startNodeDrag(e, id) {
        if (e.target.closest('select') || e.target.closest('button') || e.target.closest('textarea') || e.target.closest('.port')) return;
        e.stopPropagation(); e.preventDefault();
        dragTarget = nodeInstances.find(function(n) { return n.id === id; });
        if (!dragTarget) return;
        isDraggingNode = true;
        document.getElementById('canvasWorld').appendChild(dragTarget.el);
        dragOffset = { x: e.clientX - dragTarget.el.getBoundingClientRect().left, y: e.clientY - dragTarget.el.getBoundingClientRect().top };
        dragTarget.el.classList.add('dragging');
    }

    function onNodeTypeChange(id) {
        let inst = nodeInstances.find(function(n) { return n.id === id; });
        let select = document.getElementById(id + '-select');
        inst.nodeId = select.value; inst.name = select.options[select.selectedIndex].text;
        inst.el.querySelector('.node-title').textContent = inst.name;
        let item = document.querySelector('.comfy-context-item[data-id="' + inst.nodeId + '"]');
        if(item) { inst.icon = item.dataset.icon; inst.el.querySelector('.node-icon').className = 'node-icon ' + inst.icon; }
        inst.outputData = null; inst.el.classList.remove('done', 'error');
        document.getElementById(id + '-status').className = 'node-status-dot';
        let expandBtn = document.getElementById(id + '-expandBtn');
        if(expandBtn) expandBtn.style.display = 'none';
        document.getElementById(id + '-outputPanel').classList.remove('expanded');
    }

    function updateMonitor() {
        let monitor = document.getElementById('monitorNodeCount');
        if(monitor) monitor.innerText = nodeInstances.length;
    }

    // ==================== 5. 终极 DAG 图并发执行引擎 ====================
    async function executeWorkflow() {
        if (nodeInstances.length === 0) return;
        executionAborted = false;
        document.getElementById('btnExecute').disabled = true;
        document.getElementById('btnExecute').innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> 拓扑流转中...';
        document.getElementById('btnStop').style.display = '';

        nodeInstances.forEach(function(inst) {
            inst.el.classList.remove('executing', 'done', 'error');
            let statusDot = document.getElementById(inst.id + '-status');
            if (statusDot) statusDot.className = 'node-status-dot';
            inst.outputData = null;
            let panel = document.getElementById(inst.id + '-outputPanel');
            if(panel) panel.classList.remove('expanded');
        });

        saveCanvasToStorage();
        var nodePromises = {}, finalOutputStr = "";

        function getOrRunNode(nodeId) {
            if (!nodePromises[nodeId]) {
                nodePromises[nodeId] = (async function() {
                    var inst = nodeInstances.find(function(n) { return n.id === nodeId; });
                    if (!inst) return; // 👑 绝对防空指针1：保护本节点

                    try {
                        var preds = edges.filter(function(e) { return e.to === nodeId; }).map(function(e) { return e.from; });

                        // 等待所有上游执行完毕
                        await Promise.all(preds.map(function(p) { return getOrRunNode(p); }));
                        if (executionAborted) throw new Error("手动急停");

                        inst.el.classList.add('executing');
                        let statusDot = document.getElementById(inst.id + '-status');
                        if (statusDot) statusDot.className = 'node-status-dot running';

                        if (inst.nodeId === '-999' || inst.nodeId === '-3') {
                            let ta = inst.el.querySelector('.node-input-text');
                            let val = ta ? ta.value.trim() : "（无文本输入）";
                            inst.outputData = { output: val || "（无文本输入）", status: 'done', duration: 0, tokens: 0 };
                        } else {
                            let mergedInput = "";
                            if (preds.length === 1) {
                                let pInst = nodeInstances.find(function(n) { return n.id === preds[0]; });
                                // 👑 绝对防空指针2：安全读取上游数据
                                mergedInput = (pInst && pInst.outputData) ? pInst.outputData.output : "（上游节点未返回有效数据）";
                            } else if (preds.length > 1) {
                                mergedInput = "【多源数据汇聚】：\n";
                                preds.forEach(function(p, idx) {
                                    let pInst = nodeInstances.find(function(n) { return n.id === p; });
                                    // 👑 绝对防空指针3：安全循环读取
                                    let outTxt = (pInst && pInst.outputData) ? pInst.outputData.output : "（无数据）";
                                    mergedInput += "--- 数据源 " + (idx+1) + " ---\n" + outTxt + "\n\n";
                                });
                            }

                            let formData = new URLSearchParams();
                            formData.append('userText', mergedInput || " ");
                            formData.append('promptIds', inst.nodeId);
                            formData.append('ajax', 'true');

                            const controller = new AbortController();
                            const timeoutId = setTimeout(function() { controller.abort(); }, 60000);

                            var response = await fetch('chat', {
                                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                                body: formData.toString(), signal: controller.signal
                            });
                            clearTimeout(timeoutId);

                            if (!response.ok) throw new Error('HTTP 状态码: ' + response.status);
                            var result = await response.json();

                            // 👑 绝对防空指针4：校验后端返回的数组结构
                            if (result && result.nodeResults && result.nodeResults.length > 0) {
                                inst.outputData = result.nodeResults[0];
                                finalOutputStr = inst.outputData.output;
                                if (inst.outputData.isPPT && inst.outputData.pptData) executePPTNode(inst.outputData.pptData);
                            } else {
                                throw new Error("后端节点未返回任何结果结构");
                            }
                        }
                    } catch (err) {
                        let msg = err.name === 'AbortError' ? '后端计算超时 (>60s)' : (err.message || '系统异常');
                        inst.outputData = { output: '执行中断: ' + msg, status: 'error', duration: 0, tokens: 0 };
                        // 👑 核心修复：绝不再 `throw err`！错误被吸收并展示在节点面板，让下游节点继续正常执行
                    } finally {
                        // 👑 绝对防空指针5：兜底赋值
                        if (!inst.outputData) inst.outputData = { output: '未名崩溃', status: 'error', duration: 0, tokens: 0 };

                        inst.el.classList.remove('executing');
                        inst.el.classList.add(inst.outputData.status);

                        let sd = document.getElementById(inst.id + '-status');
                        if (sd) sd.className = 'node-status-dot ' + inst.outputData.status;

                        let expandBtn = document.getElementById(inst.id + '-expandBtn');
                        if (expandBtn) expandBtn.style.display = '';

                        let metaInfo = document.getElementById(inst.id + '-meta');
                        if (metaInfo) metaInfo.innerHTML = '<span><i class="ti ti-clock me-1"></i>' + (inst.outputData.duration || 0) + 'ms</span><span><i class="ti ti-flame me-1"></i>' + (inst.outputData.tokens || 0) + ' Token</span>';

                        let outText = inst.outputData.output || '';
                        let outputDiv = document.getElementById(inst.id + '-output');
                        if (outputDiv) outputDiv.textContent = outText.length > 500 ? outText.substring(0, 500) + '...(点击展开查看详情)' : outText;

                        let panel = document.getElementById(inst.id + '-outputPanel');
                        if (panel) panel.classList.add('expanded');
                    }
                })();
            }
            return nodePromises[nodeId];
        }

        try {
            await Promise.all(nodeInstances.map(function(inst) { return getOrRunNode(inst.id); }));
            if (finalOutputStr) showFinalResult(finalOutputStr);
            triggerConfetti();
        } catch (e) {
            console.warn('工作流引擎已安全截断');
        }

        resetExecuteButton();
    }

    function stopExecution() { executionAborted = true; resetExecuteButton(); showToast('已触发急停机制'); }
    function resetExecuteButton() {
        document.getElementById('btnExecute').disabled = false;
        document.getElementById('btnExecute').innerHTML = '<i class="ti ti-player-play me-2"></i> 启动引擎 (Run)';
        document.getElementById('btnStop').style.display = 'none';
    }

    // ==================== 6. 持久化与结果渲染 ====================
    function getCanvasJson() {
        var nodes = nodeInstances.map(function(inst) {
            let ta = inst.el.querySelector('.node-input-text');
            let val = (inst.nodeId === '-999' || inst.nodeId === '-3') && ta ? ta.value : '';
            return { nodeId: inst.nodeId, name: inst.name, icon: inst.icon, x: inst.x, y: inst.y, domId: inst.id, textValue: val };
        });
        return { nodes: nodes, edges: edges, panX: canvasPanX, panY: canvasPanY, zoom: canvasZoom, nodeIdCounter: nodeIdCounter };
    }

    function renderCanvas(jsonObj) {
        if (!jsonObj) return;
        while (nodeInstances.length > 0) nodeInstances.pop().el.remove();
        edges = [];
        if(jsonObj.panX!==undefined) canvasPanX = jsonObj.panX; if(jsonObj.panY!==undefined) canvasPanY = jsonObj.panY;
        if(jsonObj.zoom!==undefined) canvasZoom = jsonObj.zoom; if(jsonObj.nodeIdCounter!==undefined) nodeIdCounter = jsonObj.nodeIdCounter;

        if (jsonObj.nodes) {
            jsonObj.nodes.forEach(function(n) {
                let inst = createNodeInstance(n.nodeId, n.name, n.icon, n.x, n.y, n.domId);
                let ta = inst.el.querySelector('.node-input-text');
                if (n.textValue && (n.nodeId === '-999' || n.nodeId === '-3') && ta) ta.value = n.textValue;
                nodeInstances.push(inst); document.getElementById('canvasWorld').appendChild(inst.el);
            });
        }
        if (jsonObj.edges) edges = jsonObj.edges;
        applyTransform(); setTimeout(renderWires, 50); updateMonitor();
    }

    function clearCanvas() {
        tablerConfirm('清空画板', '确定清空所有节点与连线吗？', function() {
            while (nodeInstances.length > 0) nodeInstances.pop().el.remove();
            edges = []; renderWires(); updateMonitor(); showToast('已清空');
        });
    }

    function saveCanvasToStorage() { try { sessionStorage.setItem('ai_workflow_canvas_state', JSON.stringify(getCanvasJson())); } catch(e){} }
    function restoreCanvasState() { try { let s = sessionStorage.getItem('ai_workflow_canvas_state'); if(s && '${empty finalResult}'==='true') renderCanvas(JSON.parse(s)); } catch(e){} }

    function showFinalResult(text) {
        document.getElementById('finalResultBox').value = text;
        new bootstrap.Offcanvas(document.getElementById('outputOffcanvas')).show();
        if(typeof marked !== 'undefined') document.getElementById('markdown-viewer').innerHTML = marked.parse(text);
    }

    function zoomIn() { canvasZoom = Math.min(2.5, canvasZoom * 1.2); applyTransform(); renderWires(); }
    function zoomOut() { canvasZoom = Math.max(0.2, canvasZoom * 0.833); applyTransform(); renderWires(); }
    function resetView() { canvasZoom=1; canvasPanX=(CANVAS_WORLD_SIZE-document.getElementById('canvasViewport').clientWidth)/2; canvasPanY=(CANVAS_WORLD_SIZE-document.getElementById('canvasViewport').clientHeight)/2; applyTransform(); renderWires(); }
    function escapeHtml(s) { return s?s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'):''; }

    const CACHE_KEY = 'ai_workflow_local_history';
    function saveToLocalCache() { let n = prompt('暂存名称：', '工作流 ' + new Date().toLocaleTimeString()); if(n) { let h = JSON.parse(localStorage.getItem(CACHE_KEY)||'[]'); h.unshift({id: Date.now(), name: n, ts: new Date().toLocaleString(), data: getCanvasJson()}); localStorage.setItem(CACHE_KEY, JSON.stringify(h.slice(0,20))); renderLocalSidebar(); showToast('暂存成功'); } }

    function renderLocalSidebar() {
        let h = JSON.parse(localStorage.getItem(CACHE_KEY)||'[]');
        let c = document.getElementById('localWorkflowList');
        if(c) c.innerHTML = h.length ? h.map(function(i) { return '<div class="list-group-item d-flex"><div class="flex-fill" style="cursor:pointer;" onclick="loadFromCache(' + i.id + ')"><div class="fw-bold fs-6">' + escapeHtml(i.name) + '</div><div class="text-muted" style="font-size:11px;">' + i.ts + '</div></div><a href="#" class="text-danger p-2" onclick="deleteCache(' + i.id + ')"><i class="ti ti-trash"></i></a></div>'; }).join('') : '<div class="p-3 text-center text-muted">暂无缓存</div>';
    }

    function loadFromCache(id) { tablerConfirm('加载警告', '将覆盖当前画板，确认加载？', function() { let r = JSON.parse(localStorage.getItem(CACHE_KEY)||'[]').find(function(i) { return i.id===id; }); if(r) { renderCanvas(r.data); showToast('加载成功'); }}); }
    function deleteCache(id) { tablerConfirm('删除记录', '确认删除该暂存吗？', function() { localStorage.setItem(CACHE_KEY, JSON.stringify(JSON.parse(localStorage.getItem(CACHE_KEY)||'[]').filter(function(i) { return i.id!==id; }))); renderLocalSidebar(); }); }
    function exportToFile() { let b=new Blob([JSON.stringify(getCanvasJson(),null,2)],{type:'application/json'}), u=URL.createObjectURL(b), a=document.createElement('a'); a.href=u; a.download='workflow.json'; a.click(); URL.revokeObjectURL(u); }
    function importFromFile(e) { let f=e.target.files[0], r=new FileReader(); r.onload=function(ev) { try{renderCanvas(JSON.parse(ev.target.result)); showToast('导入成功');}catch(err){showToast('导入失败', 'danger');}}; if(f) r.readAsText(f); e.target.value=''; }

    async function executePPTNode(data) { let fd=new URLSearchParams(); fd.append('action','export'); fd.append('pptData',encodeURIComponent(data)); try{ let r=await fetch('pptServlet',{method:'POST',body:fd.toString(),headers:{'Content-Type':'application/x-www-form-urlencoded'}}); if(!r.ok) throw new Error(r.status); let b=await r.blob(), u=window.URL.createObjectURL(b), a=document.createElement('a'); a.href=u; a.download='AI生成汇报.pptx'; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(u); }catch(e){showToast('PPT生成失败','danger');} }

    function triggerConfetti() {
        if(typeof confetti==='undefined') return;
        let end=Date.now()+3000, d={startVelocity:30,spread:360,ticks:60,zIndex:9999};
        let interval=setInterval(function() {
            let tl=end-Date.now();
            if(tl<=0)return clearInterval(interval);
            let c=50*(tl/3000);
            confetti(Object.assign({},d,{particleCount:c,origin:{x:Math.random()*(0.3-0.1)+0.1,y:Math.random()-0.2},colors:['#26eb26','#206bc4','#f59f00','#d63939','#74b816']}));
            confetti(Object.assign({},d,{particleCount:c,origin:{x:Math.random()*(0.9-0.7)+0.7,y:Math.random()-0.2}}));
        },250);
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
<!-- 👑 动态侧滑抽屉 (Offcanvas)：装载工具与缓存 -->
<div class="offcanvas offcanvas-start" tabindex="-1" id="toolboxOffcanvas" aria-labelledby="toolboxOffcanvasLabel" style="width: 350px;">
    <div class="offcanvas-header bg-light border-bottom">
        <h3 class="offcanvas-title fw-bold" id="toolboxOffcanvasLabel"><i class="ti ti-box me-2 text-primary"></i> 工作台工具箱</h3>
        <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>
    <div class="offcanvas-body p-3 d-flex flex-column">

        <!-- 1. 引擎状态监控区 (模拟高级平台感) -->
        <div class="card bg-dark text-white border-0 shadow-sm mb-4 rounded-4 overflow-hidden">
            <div class="card-body p-3">
                <div class="d-flex align-items-center mb-2">
                    <i class="ti ti-cpu fs-2 text-primary me-2"></i>
                    <h4 class="m-0 fw-bold">DeepSeek DAG 引擎</h4>
                </div>
                <div class="d-flex justify-content-between text-muted fs-6">
                    <span>并发状态: <span class="text-success fw-bold">Ready</span></span>
                    <span>当前节点: <span id="monitorNodeCount" class="text-white fw-bold">1</span> 个</span>
                </div>
            </div>
            <!-- 一条骚气的赛博呼吸灯线条 -->
            <div style="height: 3px; background: linear-gradient(90deg, #206bc4, #4299e1, #206bc4); background-size: 200% 100%; animation: gradientMove 2s linear infinite;"></div>
        </div>

        <!-- 2. DAG 拓扑流管控区 -->
        <label class="form-label text-muted fw-bold mb-2 fs-6"><i class="ti ti-route me-1"></i>拓扑流管控</label>
        <div class="row g-2 mb-4">
            <div class="col-6">
                <button class="btn btn-outline-primary w-100" onclick="saveToLocalCache()" title="保存当前拓扑到浏览器">
                    <i class="ti ti-device-floppy me-1"></i> 本地暂存
                </button>
            </div>
            <div class="col-6">
                <button class="btn btn-outline-danger w-100" onclick="clearCanvas()" title="清空全部节点与连线">
                    <i class="ti ti-trash me-1"></i> 清空画布
                </button>
            </div>
        </div>

        <!-- 3. 文件资产流转区 -->
        <label class="form-label text-muted fw-bold mb-2 fs-6"><i class="ti ti-file-export me-1"></i>资产流转</label>
        <div class="row g-2 mb-4">
            <div class="col-6">
                <button class="btn btn-light w-100 text-dark border shadow-sm" onclick="exportToFile()" title="将拓扑导出为 JSON 文件">
                    <i class="ti ti-download text-success me-1"></i> 导出 JSON
                </button>
            </div>
            <div class="col-6">
                <input type="file" id="importJsonInput" style="display:none" accept=".json" onchange="importFromFile(event)">
                <button class="btn btn-light w-100 text-dark border shadow-sm" onclick="document.getElementById('importJsonInput').click()" title="从本地导入 JSON 工作流">
                    <i class="ti ti-upload text-warning me-1"></i> 导入 JSON
                </button>
            </div>
        </div>

        <!-- 4. 本地缓存列表区 -->
        <label class="form-label text-muted fw-bold mb-2 fs-6 mt-auto"><i class="ti ti-history me-1"></i>历史暂存记录</label>
        <div class="card shadow-sm border-primary flex-fill" style="border-top: 3px solid #206bc4; min-height: 200px;">
            <div class="list-group list-group-flush" id="localWorkflowList" style="max-height: 300px; overflow-y: auto;">
                <!-- JS 会自动把列表渲染到这里 -->
            </div>
        </div>
    </div>
</div>
<jsp:include page="footer.jsp" />
