<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<jsp:include page="header.jsp" />

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/css/jsvectormap.min.css">

<div class="page-wrapper">
    <div class="page-header d-print-none">
        <div class="container-xl">
            <div class="row g-2 align-items-center">
                <div class="col">
                    <h2 class="page-title">API 监控与安全大盘</h2>
                    <div class="text-muted mt-1">实时监控大模型接口的调用频率与地理分布。</div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="container-xl">
            <div class="row row-cards">

                <div class="col-md-6 col-xl-3">
                    <div class="card card-sm shadow-sm">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-auto"><span class="bg-primary text-white avatar"><i class="ti ti-api-app fs-2"></i></span></div>
                                <div class="col">
                                    <div class="font-weight-medium">总 API 请求次数</div>
                                    <div class="text-muted">${totalCalls} 次</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3">
                    <div class="card card-sm shadow-sm">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-auto"><span class="bg-green text-white avatar"><i class="ti ti-server fs-2"></i></span></div>
                                <div class="col">
                                    <div class="font-weight-medium">节点平均响应延迟</div>
                                    <div class="text-muted">${avgDuration} ms</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3">
                    <div class="card card-sm shadow-sm">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-auto"><span class="bg-warning text-white avatar"><i class="ti ti-bolt fs-2"></i></span></div>
                                <div class="col">
                                    <div class="font-weight-medium">Token 累计消耗</div>
                                    <div class="text-muted">${totalTokens} Tokens</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 col-xl-3">
                    <div class="card card-sm shadow-sm">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-auto"><span class="bg-red text-white avatar"><i class="ti ti-shield-x fs-2"></i></span></div>
                                <div class="col">
                                    <div class="font-weight-medium">异常拦截次数</div>
                                    <div class="text-muted">${interceptCount} 次拦截</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12">
                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h3 class="card-title">节点请求来源地理分布</h3>
                        </div>
                        <div class="card-body">
                            <div id="map-world" style="height: 400px; width: 100%;"></div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/js/jsvectormap.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/maps/world.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jsvectormap@1.5.3/dist/maps/world-merc.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        if(document.getElementById('map-world')) {
            new jsVectorMap({
                selector: '#map-world',
                map: 'world',
                backgroundColor: 'transparent',
                regionStyle: {
                    initial: {
                        fill: '#e2e8f0',
                        stroke: 'none',
                        strokeWidth: 1,
                        strokeOpacity: 1
                    }
                },
                // 模拟几个高亮数据点 (可以在后端用 Servlet 生成传过来)
                markers: [
                    { name: '北京节点 (活跃)', coords: [39.9042, 116.4074] },
                    { name: '硅谷服务器', coords: [37.7749, -122.4194] },
                    { name: '法兰克福代理', coords: [50.1109, 8.6821] }
                ],
                markerStyle: {
                    initial: { r: 6, fill: '#206bc4', stroke: '#fff', strokeWidth: 2 }
                }
            });
        }
    });
</script>

<jsp:include page="footer.jsp" />