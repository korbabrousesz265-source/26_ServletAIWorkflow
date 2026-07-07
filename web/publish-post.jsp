<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">发布工作流模板</h2>
                    <div class="text-muted mt-1">分享你的创意，让更多人使用你的 AI 工作流。</div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <form action="publish?action=add" method="post" class="card shadow-sm">
                        <div class="card-body">
                            <div class="mb-4">
                                <label class="form-label required fs-3">模板标题</label>
                                <input type="text" class="form-control form-control-lg" name="title" placeholder="例如：自动化小红书爆款文案生成器" required>
                            </div>

                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <label class="form-label required">所属分类</label>
                                    <select class="form-select" name="categoryId">
                                        <option value="效率办公">效率办公</option>
                                        <option value="自媒体运营">自媒体运营</option>
                                        <option value="编程与开发">编程与开发</option>
                                        <option value="日常生活">日常生活</option>
                                    </select>
                                </div>
                                <div class="col-md-6 mt-3 mt-md-0">
                                    <label class="form-label required">绑定工作流文件 (.json)</label>
                                    <input type="file" id="workflowFileSelector" class="form-control" accept=".json" required onchange="readWorkflowFile(this)">
                                </div>
                            </div>

                            <input type="hidden" id="workflowSnapshotInput" name="workflowSnapshot" value="">

                            <div class="mb-4">
                                <label class="form-label required">详细说明文档 <span class="text-muted fw-normal">(支持 Markdown)</span></label>
                                <textarea class="form-control" name="content" rows="12" placeholder="请详细描述这个工作流的作用、适用的场景，以及每个节点的设计思路..." required></textarea>
                            </div>

                            <div class="mb-4">
                                <label class="row">
                                    <span class="col">公开到模板市场</span>
                                    <span class="col-auto">
                                        <label class="form-check form-check-single form-switch">
                                            <input class="form-check-input" type="checkbox" name="isPublic" value="1" checked>
                                        </label>
                                    </span>
                                </label>
                                <small class="text-muted">关闭后，该模板仅你自己可在工作台中查看和使用。</small>
                            </div>
                        </div>

                        <div class="card-footer text-end bg-light">
                            <div class="d-flex">
                                <a href="chat" class="btn btn-link">取消</a>
                                <button type="submit" class="btn btn-primary ms-auto">
                                    <i class="ti ti-send me-2"></i> 立即发布
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
    /**
     * 👑 纯前端全息读取引擎：零网络开销，将选中的 JSON 文件解析为文本并注入表单
     */
    function readWorkflowFile(input) {
        const file = input.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(e) {
            try {
                // 验证是不是合法的 JSON 格式，防止用户上传有毒文件
                const jsonObj = JSON.parse(e.target.result);

                // 完美压缩并注入隐藏域
                document.getElementById('workflowSnapshotInput').value = JSON.stringify(jsonObj);
                console.log("✅ 工作流文件解析成功，全量快照已注入表单隐藏域！");
            } catch (err) {
                alert("❌ 错误：该文件不是合法的 JSON 工作流配置文件，请重新选择！");
                input.value = ''; // 清空选择
                document.getElementById('workflowSnapshotInput').value = '';
            }
        };
        reader.readAsText(file);
    }
</script>

<jsp:include page="footer.jsp" />