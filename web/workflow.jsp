<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<style>
    /* 拖拽相关高级样式 */
    .cursor-grab { cursor: grab; }
    .cursor-grab:active { cursor: grabbing; }
    .sortable-ghost { opacity: 0.3; background-color: #f8f9fa !important; border: 2px dashed #206bc4 !important; }
    .workflow-step { position: relative; transition: all 0.2s ease; }
    .workflow-step:not(:last-child)::after {
        content: ''; position: absolute; bottom: -16px; left: 45px;
        width: 2px; height: 14px; background-color: #cbd5e1; z-index: 0;
    }

    /* 历史记录列表悬浮效果 */
    .history-item { transition: background-color 0.2s; border-left: 3px solid transparent; }
    .history-item:hover { background-color: #f6f8fb; }
    .history-item.active { border-left-color: #206bc4; background-color: #f6f8fb; color: #206bc4; font-weight: bold; }

</style>

<div class="page-wrapper">
    <!-- 🔑 API Key 未配置警告 -->
    <c:if test="${showApiKeyWarning}">
        <div class="container-xl mt-3">
            <div class="alert alert-warning alert-dismissible shadow-sm" role="alert">
                <div class="d-flex align-items-center">
                    <div class="me-3">
                        <i class="ti ti-alert-triangle fs-1 text-warning"></i>
                    </div>
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
                <div class="col">
                    <h2 class="page-title">AI 工作流中心</h2>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row g-4">

                <div class="col-12 col-lg-3">

                    <div class="d-flex flex-column gap-2 mb-3">
                        <button class="btn btn-primary w-100 shadow-sm" onclick="saveToLocalCache()">
                            <i class="ti ti-device-floppy me-2"></i> 保存到浏览器
                        </button>
                        <button class="btn btn-outline-success w-100 " onclick="exportToFile()">
                            <i class="ti ti-download me-2"></i> 导出 JSON 文件
                        </button>
                        <input type="file" id="importJsonInput" style="display:none" accept=".json" onchange="importFromFile(event)">
                        <button class="btn btn-outline-warning w-100 " onclick="document.getElementById('importJsonInput').click()">
                            <i class="ti ti-upload me-2"></i> 导入本地工作流
                        </button>
                    </div>

                    <div class="card shadow-sm mb-3 border-primary" style="border-top: 2px solid #206bc4;">
                        <div class="card-header bg-light py-2">
                            <h3 class="card-title">
                                <i class="ti ti-box me-2 text-primary"></i> 本地暂存工作流
                            </h3>
                            <span class="badge bg-primary-lt ms-auto" style="font-size: 10px;">Local Cache</span>
                        </div>
                        <div class="list-group list-group-flush" id="localWorkflowList">
                        </div>
                    </div>

                </div> <div class="col-12 col-lg-9">
                <div class="row row-cards">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header border-bottom-0">
                                <h3 class="card-title">节点运行轨迹</h3>
                            </div>
                                <div class="card-body pt-0 chat-container" id="chatWindow" style="max-height: 45vh; overflow-y: auto;">
                                    <div class="card mt-3">
                                        <div class="card-header d-flex justify-content-between align-items-center">
                                            <h3 class="card-title">🚀 最终输出结果</h3>
                                            <c:if test="${not empty finalResult}">
                                                <button class="btn btn-sm btn-outline-primary" onclick="copyFinalResult()">📋 一键复制结果</button>
                                            </c:if>
                                        </div>
                                        <div class="card-body">
                                            <c:choose>
                                                <c:when test="${not empty finalResult}">
                                                    <textarea id="finalResultBox" style="display:none;">${finalResult}</textarea>
                                                    <div id="markdown-viewer" class="form-control bg-dark text-white p-4" style="min-height: 300px; overflow-y: auto; font-size: 15px; border-radius: 8px;">
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="text-muted text-center py-5">暂无输出，请在左侧连线并启动工作流。</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <c:if test="${not empty trajectoryLogs}">
                                        <div class="card mt-3">
                                            <div class="card-header">
                                                <h3 class="card-title">🔍 节点运行轨迹</h3>
                                            </div>
                                            <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                                                <c:forEach var="log" items="${trajectoryLogs}">
                                                    <div class="alert alert-secondary">
                                                        <pre style="white-space: pre-wrap; font-size: 13px; margin: 0;">${log}</pre>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <div class="card shadow-sm">
                                <div class="card-body">
                                    <form action="chat" method="post">
                                        <label class="form-label fw-bold mb-3">1. 编排 AI 节点链路 <span class="text-muted fw-normal fs-5">（按住左侧把手可拖拽排序）</span></label>

                                        <div id="nodeContainer" class="d-flex flex-column gap-3 mb-4 ps-2">
                                            <div class="workflow-step border rounded bg-white shadow-sm p-2 d-flex align-items-center" style="z-index: 1;">
                                                <i class="ti ti-grip-vertical text-muted fs-2 cursor-grab me-2 drag-handle" title="拖拽排序"></i>
                                                <span class="step-label badge bg-blue-lt me-3 px-2 py-1">步骤 1</span>
                                                <select class="form-select border-0 bg-light flex-grow-1 font-weight-bold" name="promptIds" style="cursor: pointer;">
                                                    <optgroup label="AI 算力节点 (思考与生成)">
                                                        <c:forEach var="tpl" items="${templates}">
                                                            <option value="${tpl.id}">${tpl.name}</option>
                                                        </c:forEach>
                                                    </optgroup>
                                                    <optgroup label="插件节点 (工具/输出)">
                                                        <option value="-1">🎁 导出为 PowerPoint (.pptx)</option>
                                                    </optgroup>
                                                </select>
                                                <button type="button" class="btn btn-icon btn-sm text-danger ms-2 border-0 bg-transparent" onclick="removeNode(this)">
                                                    <i class="ti ti-trash fs-3"></i>
                                                </button>
                                            </div>
                                        </div>

                                        <button type="button" class="btn btn-outline-primary btn-sm mb-4" onclick="addNode()">
                                            <i class="ti ti-plus me-1"></i> 新增下游节点
                                        </button>

                                        <div class="mb-4">
                                            <label class="form-label fw-bold">2. 初始任务内容</label>
                                            <textarea class="form-control bg-light" name="userText" rows="3" placeholder="在此输入需要第一步处理的文本..." required></textarea>
                                        </div>

                                        <button type="submit" class="btn btn-primary w-100 fw-bold py-2 fs-3">
                                            <i class="ti ti-player-play me-2"></i> 启动自动化流转
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const container = document.getElementById('nodeContainer');
        new Sortable(container, {
            animation: 250,
            handle: '.drag-handle',
            ghostClass: 'sortable-ghost',
            onEnd: function (evt) { updateStepLabels(); }
        });

        const chatWindow = document.getElementById('chatWindow');
        if(chatWindow) chatWindow.scrollTop = chatWindow.scrollHeight;
    });

    function addNode() {
        const container = document.getElementById('nodeContainer');
        const steps = container.getElementsByClassName('workflow-step');
        if (steps.length === 0) return;

        const newNode = steps[0].cloneNode(true);
        newNode.style.opacity = '0';
        newNode.style.transform = 'translateY(-10px)';

        container.appendChild(newNode);
        updateStepLabels();

        setTimeout(() => {
            newNode.style.opacity = '1';
            newNode.style.transform = 'translateY(0)';
        }, 10);
    }

    function removeNode(btn) {
        const container = document.getElementById('nodeContainer');
        if (container.children.length <= 1) {
            showToast('工作流至少需要保留一个处理节点！', 'danger');
            return;
        }

        const node = btn.closest('.workflow-step');
        node.style.opacity = '0';
        node.style.transform = 'translateX(20px)';

        setTimeout(() => {
            node.remove();
            updateStepLabels();
        }, 200);
    }

    function updateStepLabels() {
        const steps = document.getElementById('nodeContainer').getElementsByClassName('workflow-step');
        for (let i = 0; i < steps.length; i++) {
            steps[i].querySelector('.step-label').innerText = '步骤 ' + (i + 1);
        }
    }
</script>
<script>
    /**
     * 触发 PPT 导出节点
     * @param {string} aiGeneratedJsonString - 上一个大模型节点生成的纯 JSON 字符串
     */
    async function executePPTNode(aiGeneratedJsonString) {
        // 1. 显示加载动画 (可替换为你自己的 UI 逻辑)
        console.log("🚀 PPT 渲染节点启动，正在合成幻灯片...");

        // 2. 将 JSON 字符串作为参数
        const formData = new URLSearchParams();
        formData.append("action", "export");
        formData.append("pptData", encodeURIComponent(aiGeneratedJsonString));

        try {
            const response = await fetch('pptServlet', {
                method: 'POST',
                headers: {
                    // 👑 架构师修复：必须强制指定 UTF-8，否则后台收到的 JSON 键全是乱码！
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: formData.toString()
            });

            if (!response.ok) {
                throw new Error(`后端渲染失败，状态码: ${response.status}`);
            }

            // 👑 【核心黑科技】：不要用 res.json() 或 res.text()！
            // 使用 res.blob() 拦截后端的二进制流！
            const blob = await response.blob();

            // 3. 在浏览器内存中，为这个二进制文件生成一个临时的 URL
            const downloadUrl = window.URL.createObjectURL(blob);

            // 4. 使用代码创建一个隐藏的 <a> 标签，模拟用户点击下载
            const a = document.createElement('a');
            a.href = downloadUrl;
            a.download = 'AI智能生成汇报.pptx'; // 强行指定下载的文件名
            document.body.appendChild(a);
            a.click(); // 触发下载！

            // 5. 阅后即焚：销毁标签和内存中的临时链接
            a.remove();
            window.URL.revokeObjectURL(downloadUrl);

            console.log("✅ PPT 合成完毕并已触发下载！");

        } catch (error) {
            console.error("❌ PPT 生成节点执行异常:", error);
            showToast("PPT 生成失败，请检查 AI 输出的 JSON 格式是否正确！", 'danger');
        }
    }
</script>
<c:if test="${not empty autoTriggerPPT}">
    <textarea id="hiddenPptData" style="display:none;"><c:out value="${autoTriggerPPT}" /></textarea>
</c:if>

<script>
    // 当页面刷新渲染完毕后，检查是否需要自动下载 PPT
    document.addEventListener("DOMContentLoaded", function() {
        const hiddenData = document.getElementById('hiddenPptData');
        if (hiddenData && hiddenData.value) {
            // 短暂延迟 800 毫秒，让用户先看到绿色的“✅ 已成功拦截...”提示，然后再弹出下载框，体验拉满！
            setTimeout(() => {
                executePPTNode(hiddenData.value);
            }, 800);
        }
    });
</script>
<script>
    // ================= 1. 一键复制功能 =================
    function copyFinalResult() {
        const resultBox = document.getElementById("finalResultBox");
        if(resultBox) {
            resultBox.select();
            document.execCommand("copy");
            showToast("✅ 结果已成功复制到剪贴板！");
        }
    }

    // ================= 2. 画板运行状态“无感记忆”引擎 =================
    document.addEventListener("DOMContentLoaded", function() {

        // 🗑️ 1. 彻底斩草除根：清除以前遗留的“莎士比亚”脏数据
        localStorage.removeItem('myWorkflowSnapshot');

        // 🔄 2. 页面重载后，尝试从 Session (会话缓存) 中无缝恢复上一次提交的画板
        const currentStateStr = sessionStorage.getItem('ai_workflow_current_state');
        if (currentStateStr) {
            const currentState = JSON.parse(currentStateStr);
            // 👑 呼叫底层真正的反序列化主厨，一行代码还原整个节点链和输入框！
            renderCanvas(currentState);
            console.log("✅ 画板节点与输入内容已自动恢复！");
        }

        // 📸 3. 拦截表单提交：在发请求给后端前，用 1 毫秒的时间拍个快照存起来
        const form = document.querySelector('form');
        if (form) {
            form.addEventListener('submit', function() {
                // 呼叫底层真正的序列化主厨，抓取所有数据
                const currentSnapshot = getCanvasJson();
                // 存入 sessionStorage（只在当前标签页有效，比 localStorage 更安全整洁）
                sessionStorage.setItem('ai_workflow_current_state', JSON.stringify(currentSnapshot));
            });
        }
    });
</script>
<script>
    // 👑 定义浏览器本地缓存的专属 Key
    const CACHE_KEY = 'ai_workflow_local_history';

    // ================= 真正的画板序列化引擎 =================
    function getCanvasJson() {
        const selectedNodes = [];
        // 1. 抓取当前画板上所有的节点(下拉框)的值
        document.querySelectorAll('select[name="promptIds"]').forEach(select => {
            selectedNodes.push(select.value);
        });
        // 2. 抓取用户的初始任务输入
        const userText = document.querySelector('textarea[name="userText"]').value;

        return {
            nodes: selectedNodes,
            input: userText
        };
    }

    // ================= 真正的画板反序列化(重绘)引擎 =================
    function renderCanvas(jsonObj) {
        if (!jsonObj) return;

        // 1. 恢复初始任务内容
        if (jsonObj.input !== undefined) {
            document.querySelector('textarea[name="userText"]').value = jsonObj.input;
        }

        // 2. 恢复节点流转编排
        if (jsonObj.nodes && Array.isArray(jsonObj.nodes) && jsonObj.nodes.length > 0) {
            const container = document.getElementById('nodeContainer');
            const steps = container.getElementsByClassName('workflow-step');

            // 提取第一个节点作为克隆的“模具”
            const templateNode = steps[0].cloneNode(true);

            // 暴力清空当前画板上的所有节点
            container.innerHTML = '';

            // 根据 JSON 缓存中的数组，逐个克隆并恢复值
            jsonObj.nodes.forEach(nodeValue => {
                const newNode = templateNode.cloneNode(true);
                // 恢复下拉框选中项
                newNode.querySelector('select[name="promptIds"]').value = nodeValue;
                // 确保透明度和位置正常（消除新建动画的影响）
                newNode.style.opacity = '1';
                newNode.style.transform = 'translateY(0)';

                container.appendChild(newNode);
            });

            // 重新刷新 步骤1、步骤2、步骤3... 的 UI 标号
            updateStepLabels();
        }
    }

    // ================= 核心功能 1：保存到浏览器缓存 =================
    function saveToLocalCache() {
        const name = prompt("给这个暂存的工作流起个名字吧：", "未命名工作流 " + new Date().toLocaleTimeString());
        if (!name) return;

        const snapshot = getCanvasJson(); // 获取当前画板状态

        // 组装一条记录
        const record = {
            id: Date.now(), // 用时间戳做唯一ID
            name: name,
            timestamp: new Date().toLocaleString(),
            data: snapshot
        };

        // 从 localStorage 读取旧记录，如果没有则为空数组
        let history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');

        // 把新记录插到最前面
        history.unshift(record);

        // 限制最多保存 20 条，防止撑爆浏览器内存
        if (history.length > 20) history.pop();

        // 写回 localStorage
        localStorage.setItem(CACHE_KEY, JSON.stringify(history));

        renderLocalSidebar(); // 刷新侧边栏
        showToast("✅ 已秒存至浏览器本地缓存！");
    }

    // ================= 核心功能 2：渲染侧边栏列表 =================
    // ================= 核心功能 2：渲染侧边栏列表 =================
    function renderLocalSidebar() {
        let history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
        const container = document.getElementById('localWorkflowList');

        if (history.length === 0) {
            container.innerHTML = '<div class="p-3 text-center text-muted">暂无本地缓存，快去保存一个吧！</div>';
            return;
        }

        // 👑 架构师修复：在 JSP 中写 JS 模板，必须加 \ 转义 $ 符号！
        container.innerHTML = history.map(item => `
            <div class="list-group-item list-group-item-action d-flex align-items-center">
                <div class="flex-fill cursor-pointer" onclick="loadFromCache(\${item.id})">
                    <div class="fw-bold text-dark"><i class="ti ti-file-code me-2 text-muted"></i>\${item.name}</div>
                    <div class="text-muted" style="font-size: 12px; margin-left: 24px;">\${item.timestamp}</div>
                </div>
                <a href="#" class="text-danger ms-auto p-2" onclick="deleteCache(\${item.id})" title="删除">
                    <i class="ti ti-trash"></i>
                </a>
            </div>
        `).join('');
    }

    // ================= 核心功能 3：从缓存恢复到画板 =================
    function loadFromCache(id) {
        // 👑 呼叫全局 Tabler 弹窗，将业务代码包裹在回调函数里
        tablerConfirm(
            "覆盖画板警告",
            "加载新工作流将覆盖当前画板上的所有未保存内容，您确认加载吗？",
            function() {
                let history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
                const record = history.find(item => item.id === id);
                if (record) {
                    renderCanvas(record.data); // 调用画板的渲染引擎
                    // 将原来的 showToast(`✅ 成功恢复：${record.name}`); 替换为：
                    showToast("✅ 成功恢复：" + record.name);
                }
            }
        );
    }

    // ================= 核心功能 4：删除某条缓存 =================
    function deleteCache(id) {
        // 👑 呼叫全局 Tabler 弹窗
        tablerConfirm(
            "彻底删除",
            "确定要删除这条本地暂存记录吗？删除后无法恢复！",
            function() {
                let history = JSON.parse(localStorage.getItem(CACHE_KEY) || '[]');
                history = history.filter(item => item.id !== id);
                localStorage.setItem(CACHE_KEY, JSON.stringify(history));
                renderLocalSidebar(); // 刷新列表
            }
        );
    }

    // ================= 核心功能 5：按需导出为本地 JSON 文件 =================
    function exportToFile() {
        const canvasData = getCanvasJson();
        const jsonStr = JSON.stringify(canvasData, null, 2);

        const blob = new Blob([jsonStr], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;

        // 👑 架构师修复：这里直接退回使用最传统、最安全的字符串拼接，彻底避开 JSP 的雷区！
        a.download = 'workflow_' + new Date().getTime() + '.json';

        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    // ================= 核心功能 6：导入本地 JSON 文件 =================
    function importFromFile(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(e) {
            try {
                const jsonObj = JSON.parse(e.target.result);
                renderCanvas(jsonObj);
                showToast("✅ 文件导入并解析成功！");
            } catch (err) {
                showToast("❌ 导入失败，不是合法的 JSON 工作流文件！", 'danger');
            }
            // 清空 input 的值，保证下次选同一个文件也能触发 change 事件
            event.target.value = '';
        };
        reader.readAsText(file);
    }

    // 页面加载完成后自动渲染侧边栏
    document.addEventListener("DOMContentLoaded", renderLocalSidebar);
</script>
<script src="https://cdn.jsdelivr.net/npm/canvas-confetti@1.6.0/dist/confetti.browser.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // 检查页面上是否有最终输出结果框，并且里面有内容
        const resultBox = document.getElementById('finalResultBox');
        if (resultBox && resultBox.value.trim() !== '') {
            // 延迟 500 毫秒，等页面渲染稳了再放礼花
            setTimeout(() => {
                var duration = 3 * 1000;
                var animationEnd = Date.now() + duration;
                var defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 9999 };

                function randomInRange(min, max) {
                    return Math.random() * (max - min) + min;
                }

                // 左右两边同时发射五彩纸屑
                var interval = setInterval(function() {
                    var timeLeft = animationEnd - Date.now();
                    if (timeLeft <= 0) {
                        return clearInterval(interval);
                    }
                    var particleCount = 50 * (timeLeft / duration);
                    confetti(Object.assign({}, defaults, {
                        particleCount,
                        origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 },
                        colors: ['#26eb26', '#206bc4', '#f59f00', '#d63939', '#74b816']
                    }));
                    confetti(Object.assign({}, defaults, {
                        particleCount,
                        origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 },
                        colors: ['#26eb26', '#206bc4', '#f59f00', '#d63939', '#74b816']
                    }));
                }, 250);
            }, 500);
        }
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/atom-one-dark.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const rawText = document.getElementById('finalResultBox')?.value;
        const viewer = document.getElementById('markdown-viewer');

        if (rawText && viewer) {
            // 配置 marked 引擎接入 highlight.js
            marked.setOptions({
                highlight: function(code, lang) {
                    const language = hljs.getLanguage(lang) ? lang : 'plaintext';
                    return hljs.highlight(code, { language }).value;
                }
            });
            // 渲染并点亮代码！
            viewer.innerHTML = marked.parse(rawText);
        }
    });
</script>
<jsp:include page="footer.jsp" />