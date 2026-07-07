<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">帮助中心 & 常见问题</h2>
                    <div class="text-muted mt-1">在这里你可以找到关于 AI 工作流引擎的一切操作指南。</div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <div class="accordion" id="accordion-faq">

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="heading-1">
                                        <button class="accordion-button fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq-1">
                                            什么是“AI 节点”？
                                        </button>
                                    </h2>
                                    <div id="faq-1" class="accordion-collapse collapse show" data-bs-parent="#accordion-faq">
                                        <div class="accordion-body pt-0 text-muted">
                                            AI 节点是构成工作流的最小单元。每个节点代表一种特定的 AI 能力（如：翻译、总结、代码生成）。你可以通过拖拽排序，将上一个节点的输出作为下一个节点的输入，从而实现复杂的自动化任务。
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="heading-2">
                                        <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq-2">
                                            如何配置 API Key？
                                        </button>
                                    </h2>
                                    <div id="faq-2" class="accordion-collapse collapse" data-bs-parent="#accordion-faq">
                                        <div class="accordion-body pt-0 text-muted">
                                            点击右上角头像进入“个人主页”，在“API Key 管理”区块中输入你从 OpenAI 或 DeepSeek 官网获取的密钥并保存。系统将加密存储这些密钥，仅用于你个人的工作流执行。
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="heading-3">
                                        <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq-3">
                                            Token 是如何计算消耗的？
                                        </button>
                                    </h2>
                                    <div id="faq-3" class="accordion-collapse collapse" data-bs-parent="#accordion-faq">
                                        <div class="accordion-body pt-0 text-muted">
                                            Token 消耗取决于你输入的文本长度和 AI 返回的内容长度。一般来说，1000 个汉字约等于 1500~2000 个 Token。你可以在“运行审计日志”中查看每一次执行的详细消耗明细。
                                        </div>
                                    </div>
                                </div>

                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="heading-4">
                                        <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#faq-4">
                                            如何分享我的模板到社区？
                                        </button>
                                    </h2>
                                    <div id="faq-4" class="accordion-collapse collapse" data-bs-parent="#accordion-faq">
                                        <div class="accordion-body pt-0 text-muted">
                                            在“模板社区”点击“分享我的工作流”，填写模板名称和说明文档即可发布。你可以选择将其公开（所有人可见）或设为私有。
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp" />