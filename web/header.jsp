<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"/>
    <title>AI 工作流代理平台</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/core@1.0.0-beta20/dist/css/tabler.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/tabler-icons.min.css">

    <style>
        /* 🛡️ 强制修复：导航栏悬停文字消失/变白问题 */
        .navbar .nav-item .nav-link:hover,
        .navbar .nav-item .nav-link:focus,
        .navbar .nav-item.show .nav-link {
            color: #206bc4 !important; /* 强制悬停时变为主色调蓝，绝不消失！ */
            opacity: 1 !important;     /* 强制完全不透明 */
            background-color: transparent !important; /* 防止背景色突变遮挡文字 */
            transition: color 0.2s ease-in-out; /* 补回一个丝滑的变色过渡 */
        }

        /* 确保图标（如果有）也能跟着丝滑变色 */
        .navbar .nav-item .nav-link:hover .nav-link-icon i,
        .navbar .nav-item.show .nav-link .nav-link-icon i {
            color: #206bc4 !important;
        }
        /* 魔法 CSS 2.0：悬停下拉菜单精准定位版 */
        @media (min-width: 992px) {
            .hover-dropdown { position: relative; }
            .hover-dropdown:hover .dropdown-menu {
                display: block;
                position: absolute;
                top: 100%;
                right: 0;
                left: auto;
                margin-top: 0;
                animation: fade-in 0.2s ease-out;
            }
        }
        @keyframes fade-in {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="layout-fluid">
<div class="page">
    <header class="navbar navbar-expand-md navbar-dark d-print-none">
        <div class="container-xl">
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar-menu" aria-controls="navbar-menu" aria-expanded="false" aria-label="切换导航">
                <span class="navbar-toggler-icon"></span>
            </button>

            <h1 class="navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3">
                <a href="chat" class="text-decoration-none d-flex align-items-center">
                    <i class="ti ti-brand-openai text-primary" style="font-size: 1.8rem;"></i>
                    <span class="ms-2">AI Workflow</span>
                </a>
            </h1>

            <div class="navbar-nav flex-row order-md-last">
                <div class="nav-item dropdown hover-dropdown">
                    <a href="#" class="nav-link d-flex lh-1 text-reset p-0" data-bs-toggle="dropdown" aria-label="打开用户菜单">
                        <span class="avatar avatar-sm bg-blue-lt">
                            <i class="ti ti-user fs-2"></i>
                            <span class="badge bg-red badge-blink"></span>
                        </span>
                        <div class="d-none d-xl-block ps-2">
                            <div class="fw-bold">${not empty sessionScope.username ? sessionScope.username : '未登录访客'}</div>
                            <div class="mt-1 small text-muted">${not empty sessionScope.username ? '正式用户' : '请先登录'}</div>
                        </div>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end dropdown-menu-arrow shadow-sm">
                        <a href="/profile" class="dropdown-item">
                            <i class="ti ti-user-circle me-2"></i> 个人主页
                        </a>
                        <a href="/messages" class="dropdown-item">
                            <i class="ti ti-bell me-2"></i> 消息通知
                            <span class="badge bg-red ms-auto">3</span>
                        </a>
                        <a href="/profile" class="dropdown-item">
                            <i class="ti ti-key me-2"></i> API Key 管理
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="/logout" class="dropdown-item text-danger">
                            <i class="ti ti-logout me-2"></i> 退出系统
                        </a>
                    </div>
                </div>
            </div>

            <div class="collapse navbar-collapse" id="navbar-menu">
                <div class="d-flex flex-column flex-md-row flex-fill align-items-stretch align-items-md-center">
                    <ul class="navbar-nav">
                        <li class="nav-item">
                            <a class="nav-link fw-bold text-primary" href="/chat">
                                <span class="nav-link-icon d-md-none d-lg-inline-block"><i class="ti ti-rocket"></i></span>
                                <span class="nav-link-title">AI 工作台</span>
                            </a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="/node-market">
                                <span class="nav-link-icon d-md-none d-lg-inline-block"><i class="ti ti-apps"></i></span>
                                <span class="nav-link-title">节点市场</span>
                            </a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="/forum">
                                <span class="nav-link-icon d-md-none d-lg-inline-block"><i class="ti ti-planet"></i></span>
                                <span class="nav-link-title">模板社区</span>
                            </a>
                        </li>

                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#navbar-manage" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="false">
                                <span class="nav-link-icon d-md-none d-lg-inline-block"><i class="ti ti-dashboard"></i></span>
                                <span class="nav-link-title">系统大盘</span>
                            </a>
                            <div class="dropdown-menu">
                                <a class="dropdown-item" href="/history">
                                    <i class="ti ti-history me-2 text-muted"></i> 运行审计日志
                                </a>
                                <a class="dropdown-item" href="/security-dash">
                                    <i class="ti ti-shield-lock me-2 text-muted"></i> API 监控看板
                                </a>
                            </div>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="/faq.jsp">
                                <span class="nav-link-icon d-md-none d-lg-inline-block"><i class="ti ti-help"></i></span>
                                <span class="nav-link-title">帮助说明</span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </header>