<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>注册 - AI 工作流平台</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
</head>
<body class="d-flex flex-column bg-light">
<div class="page page-center">
    <div class="container container-tight py-4">
        <div class="text-center mb-4">
            <a href="#" class="navbar-brand navbar-brand-autodark">
                <h1 class="m-0 text-primary">AI Workflow 创建账号</h1>
            </a>
        </div>

        <form class="card card-md shadow-sm" action="register" method="post">
            <div class="card-body">
                <h2 class="card-title text-center mb-4">加入我们</h2>

                <c:if test="${not empty msg}">
                    <div class="alert alert-danger" role="alert">
                        <i class="ti ti-alert-circle me-2"></i> ${msg}
                    </div>
                </c:if>

                <div class="mb-3">
                    <label class="form-label">用户名</label>
                    <input type="text" class="form-control" name="username" placeholder="设置你的系统用户名" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">邮箱地址</label>
                    <input type="email" class="form-control" name="email" placeholder="例如：user@workflow.com" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">密码</label>
                    <input type="password" class="form-control" name="password" placeholder="至少包含 6 位字符" required>
                </div>
                <div class="form-footer">
                    <button type="submit" class="btn btn-success w-100 fw-bold">注 册 新 账 号</button>
                </div>
            </div>
        </form>
        <div class="text-center text-muted mt-3">
            已有账号? <a href="login.jsp" tabindex="-1">直接登录</a>
        </div>
    </div>
</div>
</body>
</html>