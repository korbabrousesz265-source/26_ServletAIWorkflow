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
</body>
</html>