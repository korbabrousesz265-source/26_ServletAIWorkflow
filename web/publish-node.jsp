<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="container-xl mt-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="mb-4">
                    <h2 class="page-title fs-1">创造 AI 节点</h2>
                    <div class="text-muted mt-2 fs-4">编写 Prompt，封装你独有的 AI 能力并发布到全站市场。</div>
                </div>

                <form action="node-market?action=add" method="post" class="card shadow-sm border-0">
                    <div class="card-body p-5">

                        <div class="row mb-4">
                            <div class="col-md-8">
                                <label class="form-label required fs-4">节点名称</label>
                                <input type="text" class="form-control form-control-lg" name="name" placeholder="例如：小红书爆款文案改写" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label required fs-4">预估消耗 (Tokens)</label>
                                <select class="form-select form-select-lg" name="tokenCost">
                                    <option value="100">100 (轻量处理)</option>
                                    <option value="500" selected>500 (标准生成)</option>
                                    <option value="1500">1500 (深度推理)</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label required fs-4">一句话功能描述</label>
                            <input type="text" class="form-control" name="description" placeholder="清晰描述该节点能帮用户解决什么问题..." required>
                        </div>

                        <div class="mb-4">
                            <label class="form-label required fs-4">选择一个外观图标</label>
                            <div class="form-selectgroup">
                                <label class="form-selectgroup-item">
                                    <input type="radio" name="icon" value="ti ti-robot" class="form-selectgroup-input" checked>
                                    <span class="form-selectgroup-label"><i class="ti ti-robot fs-2"></i></span>
                                </label>
                                <label class="form-selectgroup-item">
                                    <input type="radio" name="icon" value="ti ti-writing" class="form-selectgroup-input">
                                    <span class="form-selectgroup-label"><i class="ti ti-writing fs-2"></i></span>
                                </label>
                                <label class="form-selectgroup-item">
                                    <input type="radio" name="icon" value="ti ti-code" class="form-selectgroup-input">
                                    <span class="form-selectgroup-label"><i class="ti ti-code fs-2"></i></span>
                                </label>
                                <label class="form-selectgroup-item">
                                    <input type="radio" name="icon" value="ti ti-language" class="form-selectgroup-input">
                                    <span class="form-selectgroup-label"><i class="ti ti-language fs-2"></i></span>
                                </label>
                                <label class="form-selectgroup-item">
                                    <input type="radio" name="icon" value="ti ti-wand" class="form-selectgroup-input">
                                    <span class="form-selectgroup-label"><i class="ti ti-wand fs-2"></i></span>
                                </label>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label required fs-4 d-flex justify-content-between">
                                <span>底层指令 (System Prompt)</span>
                                <span class="badge bg-purple-lt">核心大模型护城河</span>
                            </label>
                            <textarea class="form-control font-monospace" name="systemPrompt" rows="10" placeholder="你是一个精通XXX的专家。请严格按照以下规则处理用户的输入：&#10;1. ...&#10;2. ..." required></textarea>
                            <small class="form-hint mt-2">提示：请使用 Markdown 语法排版，指令越清晰，节点运行效果越好。该指令对所有使用者可见。</small>
                        </div>

                        <div class="alert alert-important alert-warning mt-4 mb-0" role="alert">
                            <div class="d-flex">
                                <div><i class="ti ti-shield-check me-2 fs-2"></i></div>
                                <div>
                                    <strong>🛡️ 审核提示：</strong>提交后节点将进入<strong>管理员审核流程</strong>，审核通过后才会在节点市场公开展示。
                                    请确保 System Prompt 不包含违规内容和 Prompt 注入攻击指令。
                                </div>
                            </div>
                        </div>

                    </div>
                    <div class="card-footer bg-light text-end p-4">
                        <a href="node-market" class="btn btn-link link-secondary">取消</a>
                        <button type="submit" class="btn btn-primary ms-3 px-4">
                            <i class="ti ti-rocket me-2"></i> 提交审核
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />