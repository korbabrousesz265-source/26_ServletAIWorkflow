<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">工作流模板社区</h2>
                    <div class="text-muted mt-1">发现大神们的高效工作流，一键克隆到你的工作台。</div>
                </div>
                <div class="col-auto ms-auto d-print-none">
                    <div class="btn-list">
                        <a href="publish-post.jsp" class="btn btn-primary d-none d-sm-inline-block">
                            <i class="ti ti-plus me-2"></i> 分享我的工作流
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-xl mt-3">
        <ul class="nav nav-tabs">
            <li class="nav-item">
                <a href="forum?action=index" class="nav-link ${empty currentCategory ? 'active' : ''}">全部推荐</a>
            </li>
            <li class="nav-item">
                <a href="forum?action=index&category=效率办公" class="nav-link ${currentCategory == '效率办公' ? 'active' : ''}">效率办公</a>
            </li>
            <li class="nav-item">
                <a href="forum?action=index&category=自媒体运营" class="nav-link ${currentCategory == '自媒体运营' ? 'active' : ''}">自媒体运营</a>
            </li>
            <li class="nav-item">
                <a href="forum?action=index&category=编程与开发" class="nav-link ${currentCategory == '编程与开发' ? 'active' : ''}">编程与开发</a>
            </li>
            <li class="nav-item">
                <a href="forum?action=index&category=日常生活" class="nav-link ${currentCategory == '日常生活' ? 'active' : ''}">日常生活</a>
            </li>
        </ul>
    </div>

    <div class="page-body mt-3">
        <div class="container-xl">
            <div class="row row-cards">

                <c:forEach var="post" items="${postList}">
                    <div class="col-md-6 col-xl-4">
                        <a href="forum?action=detail&id=${post.id}" class="card card-link card-link-pop">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-3">
                    <span class="avatar avatar-sm rounded bg-blue-lt">
                            ${not empty post.authorName ? post.authorName.substring(0,1) : 'A'}
                    </span>
                                    <div class="ms-2">
                                        <div class="fw-bold fs-4">${post.authorName}</div>
                                    </div>
                                    <div class="ms-auto text-muted fs-5">${post.createTime}</div>
                                </div>

                                <h3 class="card-title text-truncate">${post.title}</h3>
                                <p class="text-muted text-truncate" style="height: 3rem; white-space: normal;">
                                        ${post.content.length() > 50 ? post.content.substring(0, 50).concat('...') : post.content}
                                </p>
                            </div>
                            <div class="card-footer d-flex align-items-center bg-light">
                                <span class="badge bg-primary-lt">${post.category}</span>
                            </div>
                        </a>
                    </div>
                </c:forEach>

                <c:if test="${empty postList}">
                    <div class="col-md-6 col-xl-4">
                        <a href="post-detail.jsp" class="card card-link card-link-pop shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-3">
                                    <span class="avatar avatar-sm rounded bg-blue-lt">A</span>
                                    <div class="ms-2"><div class="fw-bold fs-4">Alex Admin</div></div>
                                    <div class="ms-auto text-muted fs-5">2 小时前</div>
                                </div>
                                <h3 class="card-title fs-2 mb-2">自动化小红书爆款文案生成器</h3>
                                <p class="text-muted" style="height: 3rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">包含卖点提取、GPT-4o口吻重写和Tag生成的完整工作流，极大提高运营产出效率。</p>
                            </div>
                            <div class="card-footer d-flex align-items-center bg-light border-top-0">
                                <span class="badge bg-purple-lt">自媒体运营</span>
                                <div class="ms-auto text-muted fw-bold">
                                    <i class="ti ti-heart text-pink me-1"></i> 124
                                    <i class="ti ti-message ms-3 me-1"></i> 18
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="col-md-6 col-xl-4">
                        <a href="post-detail.jsp" class="card card-link card-link-pop shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-3">
                                    <span class="avatar avatar-sm rounded bg-green-lt">E</span>
                                    <div class="ms-2"><div class="fw-bold fs-4">Echo Tech</div></div>
                                    <div class="ms-auto text-muted fs-5">昨天</div>
                                </div>
                                <h3 class="card-title fs-2 mb-2">Java 报错日志深度解析与修复建议</h3>
                                <p class="text-muted" style="height: 3rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">直接粘贴 Tomcat 报错堆栈，自动过滤无用信息并结合 StackOverflow 给出修改代码。</p>
                            </div>
                            <div class="card-footer d-flex align-items-center bg-light border-top-0">
                                <span class="badge bg-blue-lt">编程与开发</span>
                                <div class="ms-auto text-muted fw-bold">
                                    <i class="ti ti-heart me-1"></i> 89
                                    <i class="ti ti-message ms-3 me-1"></i> 5
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="col-md-6 col-xl-4">
                        <a href="post-detail.jsp" class="card card-link card-link-pop shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-3">
                                    <span class="avatar avatar-sm rounded bg-orange-lt">G</span>
                                    <div class="ms-2"><div class="fw-bold fs-4">Gideon</div></div>
                                    <div class="ms-auto text-muted fs-5">3 天前</div>
                                </div>
                                <h3 class="card-title fs-2 mb-2">周报自动生成大师 (打工人必备)</h3>
                                <p class="text-muted" style="height: 3rem; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">输入零散的日常记录，AI自动按照 STAR 法则扩写为高逼格的结构化团队周报。</p>
                            </div>
                            <div class="card-footer d-flex align-items-center bg-light border-top-0">
                                <span class="badge bg-teal-lt">效率办公</span>
                                <div class="ms-auto text-muted fw-bold">
                                    <i class="ti ti-heart me-1"></i> 342
                                    <i class="ti ti-message ms-3 me-1"></i> 67
                                </div>
                            </div>
                        </a>
                    </div>
                </c:if>

            </div>
        </div>
    </div>
</div>
<jsp:include page="footer.jsp" />