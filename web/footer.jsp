<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<footer class="footer footer-transparent d-print-none">
    <div class="container-xl">
        <div class="row text-center align-items-center">
            <div class="col-12 mt-3 mt-lg-0 text-muted">
                期末项目：基于 Servlet + MyBatis 的 AI 工作流引擎
            </div>
        </div>
    </div>
</footer>
</div> <script src="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/js/tabler.min.js"></script>
<!-- 🔔 动态获取未读消息数量 -->
<script>
(function() {
    var badge = document.getElementById('unreadBadge');
    if (!badge) return;
    fetch('/messages?action=unreadCount')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (data.count > 0) {
                badge.textContent = data.count;
                badge.style.display = '';
            }
        })
        .catch(function() { /* 静默失败 */ });
})();
</script>
<!-- 🍞 全局 Toast 轻提示（替代原生 alert） -->
<script>
    function showToast(message, type = 'success') {
        const bgClass = type === 'success' ? 'bg-green' : 'bg-red';
        const icon = type === 'success' ? 'ti-check' : 'ti-x';

        let toastContainer = document.getElementById('toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'toast-container';
            toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
            toastContainer.style.zIndex = '1055';
            document.body.appendChild(toastContainer);
        }

        // 2. 动态构建 Toast 元素
        const toastEl = document.createElement('div');
        // 👑 修复：避免使用模板字符串，防止被 JSP 引擎误杀
        toastEl.className = 'toast align-items-center text-white ' + bgClass + ' border-0 shadow-lg';
        toastEl.setAttribute('role', 'alert');
        toastEl.setAttribute('aria-live', 'assertive');
        toastEl.setAttribute('aria-atomic', 'true');

        // 👑 修复：全部改用加号拼接！
        toastEl.innerHTML =
            '<div class="d-flex">' +
            '<div class="toast-body fs-4 fw-bold">' +
            '<i class="ti ' + icon + ' me-2 fs-3"></i> ' + message +
            '</div>' +
            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
            '</div>';

        toastContainer.appendChild(toastEl);

        const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
        toast.show();

        toastEl.addEventListener('hidden.bs.toast', () => {
            toastEl.remove();
        });
    }
</script>
<!-- ========== Tabler 全局确认弹窗 ========== -->
<div class="modal modal-blur fade" id="globalConfirmModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered" role="document">
        <div class="modal-content shadow-lg border-0">
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            <div class="modal-status bg-danger"></div>
            <div class="modal-body text-center py-4">
                <i class="ti ti-alert-triangle text-danger mb-2" style="font-size: 3.5rem;"></i>
                <h3 id="confirmModalTitle" class="fw-bold">确认操作</h3>
                <div class="text-muted fs-4" id="confirmModalText">您确定要执行此操作吗？</div>
            </div>
            <div class="modal-footer bg-light">
                <div class="w-100">
                    <div class="row">
                        <div class="col">
                            <a href="#" class="btn w-100" data-bs-dismiss="modal">取消</a>
                        </div>
                        <div class="col">
                            <a href="#" class="btn btn-danger w-100 fw-bold" id="confirmModalBtn">确定执行</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    /**
     * 👑 架构师封装的全局弹窗调用器
     * 完美替代原生的 confirm() 方法
     * @param title 标题
     * @param text 提示内容
     * @param onConfirm 点击确定后的回调函数
     */
    function tablerConfirm(title, text, onConfirm) {
        // 1. 动态填入文字
        document.getElementById('confirmModalTitle').innerText = title;
        document.getElementById('confirmModalText').innerText = text;

        const confirmBtn = document.getElementById('confirmModalBtn');

        // 2. 深度清理旧的事件监听器 (防止多次点击叠加触发)
        const newBtn = confirmBtn.cloneNode(true);
        confirmBtn.parentNode.replaceChild(newBtn, confirmBtn);

        // 3. 绑定新的确定事件
        newBtn.addEventListener('click', function(e) {
            e.preventDefault();
            // 关闭弹窗
            const modalElement = document.getElementById('globalConfirmModal');
            const modalInstance = bootstrap.Modal.getInstance(modalElement) || new bootstrap.Modal(modalElement);
            modalInstance.hide();
            // 执行你要做的业务代码
            if (onConfirm) onConfirm();
        });

        // 4. 呼出弹窗
        const modalElement = document.getElementById('globalConfirmModal');
        const modalInstance = new bootstrap.Modal(modalElement);
        modalInstance.show();
    }
</script>

<!-- 🔔 未读消息顶部浮窗 -->
<style>
    .unread-float-bar {
        position: fixed;
        top: -80px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        max-width: 600px;
        width: 90%;
        background: #ffffff;
        border: 1px solid #dce1e7;
        border-radius: 10px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.15);
        padding: 14px 18px;
        display: flex;
        align-items: flex-start;
        gap: 12px;
        transition: top 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        cursor: pointer;
    }
    .unread-float-bar.show { top: 16px; }
    .unread-float-bar .float-icon {
        font-size: 28px;
        flex-shrink: 0;
        width: 44px; height: 44px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
    }
    .unread-float-bar .float-icon.icon-blue { background: #e8f0fe; color: #206bc4; }
    .unread-float-bar .float-icon.icon-red { background: #fde8e8; color: #d63939; }
    .unread-float-bar .float-icon.icon-green { background: #e6f7e6; color: #2fb344; }
    .unread-float-bar .float-icon.icon-yellow { background: #fef3e0; color: #f59f00; }
    .unread-float-bar .float-body { flex: 1; min-width: 0; }
    .unread-float-bar .float-title { font-weight: 700; font-size: 15px; color: #1e293b; margin-bottom: 2px; }
    .unread-float-bar .float-content { font-size: 13px; color: #6c757d; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 420px; }
    .unread-float-bar .float-close {
        flex-shrink: 0;
        background: none; border: none;
        color: #adb5bd; font-size: 18px;
        cursor: pointer; padding: 2px 6px;
        line-height: 1;
    }
    .unread-float-bar .float-close:hover { color: #495057; }
</style>

<script>
(function() {
    fetch('/messages?action=latestUnread')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if (!data.hasMsg) return;

            var iconColor = 'icon-blue';
            if (data.icon) {
                if (data.icon.indexOf('alert') >= 0 || data.icon.indexOf('warning') >= 0) iconColor = 'icon-red';
                else if (data.icon.indexOf('gift') >= 0 || data.icon.indexOf('check') >= 0 || data.icon.indexOf('coin') >= 0) iconColor = 'icon-green';
                else if (data.icon.indexOf('star') >= 0 || data.icon.indexOf('rocket') >= 0) iconColor = 'icon-yellow';
            }

            var iconName = data.icon || 'bell';
            var iconMap = { 'thumb-up': 'thumb-up', 'message-2': 'message-2', 'bell-ring': 'bell-ring',
                'speakerphone': 'speakerphone', 'gift': 'gift', 'star': 'star', 'rocket': 'rocket',
                'shield-check': 'shield-check', 'coin': 'coin', 'tools': 'tools', 'check': 'check' };
            iconName = iconMap[iconName] || 'bell';

            var bar = document.createElement('div');
            bar.className = 'unread-float-bar';
            bar.innerHTML =
                '<div class="float-icon ' + iconColor + '"><i class="ti ti-' + iconName + ' fs-2"></i></div>' +
                '<div class="float-body">' +
                '<div class="float-title">' + escapeHtml(data.title) + '</div>' +
                '<div class="float-content">' + escapeHtml(data.content) + '</div>' +
                '</div>' +
                '<button class="float-close">&times;</button>';

            document.body.appendChild(bar);

            setTimeout(function() { bar.classList.add('show'); }, 300);

            bar.querySelector('.float-close').addEventListener('click', function(e) {
                e.stopPropagation();
                bar.classList.remove('show');
                setTimeout(function() { if (bar.parentNode) bar.remove(); }, 500);
            });

            bar.addEventListener('click', function() {
                if (data.link) window.location.href = data.link;
            });

            setTimeout(function() {
                if (bar.parentNode) {
                    bar.classList.remove('show');
                    setTimeout(function() { if (bar.parentNode) bar.remove(); }, 500);
                }
            }, 6000);
        })
        .catch(function() {});
})();
</script>
</body>
</html>