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
</body>
</html>