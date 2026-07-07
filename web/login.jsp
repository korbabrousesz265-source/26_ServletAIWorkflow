<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>登录 - AI 工作流平台</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">
</head>
<body class="d-flex flex-column bg-light">
<div class="page page-center">
    <div class="container container-tight py-4">
        <div class="text-center mb-4">
            <a href="#" class="navbar-brand navbar-brand-autodark">
                <i class="ti ti-brand-openai text-primary" style="font-size: 3rem;"></i>
                <h1 class="m-0 mt-2">AI Workflow</h1>
            </a>
        </div>

        <form class="card card-md shadow-sm" action="login" method="post" autocomplete="off">
            <div class="card-body">
                <h2 class="card-title text-center mb-4">欢迎回来，请登录账号</h2>

                <c:if test="${not empty msg}">
                    <div class="alert alert-danger" role="alert">
                        <i class="ti ti-alert-circle me-2"></i> ${msg}
                    </div>
                    <c:remove var="msg" scope="session" />
                </c:if>

                <div class="mb-3">
                    <label class="form-label">用户名</label>
                    <input type="text" class="form-control" name="username" placeholder="请输入你的用户名" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">
                        密码
                        <span class="form-label-description"><a href="#">忘记密码?</a></span>
                    </label>
                    <input type="password" class="form-control" name="password" placeholder="请输入密码" required>
                </div>
                <div class="mb-3">
                    <label class="form-check">
                        <input name="rememberMe" type="checkbox" class="form-check-input"/>
                        <span class="form-check-label">记住我</span>
                    </label>
                </div>
                <div class="form-footer">
                    <button type="submit" class="btn btn-primary w-100 fw-bold">登 录</button>
                </div>
            </div>
        </form>
        <div class="text-center text-muted mt-3">
            还没有账号? <a href="register.jsp" tabindex="-1">点击注册</a>
        </div>
    </div>
</div>
</body>
</html>