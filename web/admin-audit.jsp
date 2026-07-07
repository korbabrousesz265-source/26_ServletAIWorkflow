<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:include page="header.jsp" />

<div class="page-wrapper">
    <div class="container-xl">
        <div class="row row-cards mb-3">
            <div class="col-sm-6 col-lg-4">
                <div class="card card-sm">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-auto"><span class="bg-primary text-white avatar"><i class="ti ti-users"></i></span></div>
                            <div class="col">
                                <div class="font-weight-medium">系统总用户</div>
                                <div class="text-muted">${totalUsers} 位注册成员</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-4">
                <div class="card card-sm">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-auto"><span class="bg-green text-white avatar"><i class="ti ti-api-app"></i></span></div>
                            <div class="col">
                                <div class="font-weight-medium">AI 累计调用</div>
                                <div class="text-muted">${totalCalls} 次请求</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-lg-4">
                <div class="card card-sm">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-auto"><span class="bg-warning text-white avatar"><i class="ti ti-bolt"></i></span></div>
                            <div class="col">
                                <div class="font-weight-medium">Tokens 消耗总量</div>
                                <div class="text-muted">${totalTokens} Tokens</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mb-3">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <h3 class="card-title">系统近7日 AI 调用量趋势</h3>
                        <div id="chart-trend" style="height: 250px;"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><h3 class="card-title">全站运行轨迹审计</h3></div>
            <div class="table-responsive">
                <table class="table table-vcenter card-table">
                    <thead>
                    <tr>
                        <th>用户ID</th>
                        <th>工作流名称</th>
                        <th>触发节点</th>
                        <th>消耗 Token</th>
                        <th>执行时长</th>
                        <th>触发时间</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="log" items="${allLogs}">
                        <tr>
                            <td><span class="badge bg-blue-lt"># ${log.userId}</span></td>
                            <td class="fw-bold">${log.workflowName}</td>
                            <td><span class="status status-purple">${log.nodeName}</span></td>
                            <td class="text-warning fw-bold">${log.tokenUsed}</td>
                            <td class="text-muted">${log.duration} ms</td>
                            <td>${log.createTime}</td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const rawData = ${trendData}; // 从 Servlet 传来的 JSON
        const dates = rawData.map(d => d.date);
        const counts = rawData.map(d => d.count);

        new ApexCharts(document.getElementById('chart-trend'), {
            chart: { type: 'area', height: 250, toolbar: {show: false} },
            series: [{ name: '调用次数', data: counts }],
            xaxis: { categories: dates },
            colors: ['#206bc4'],
            stroke: { curve: 'smooth', width: 2 }
        }).render();
    });
</script>
<jsp:include page="footer.jsp" />