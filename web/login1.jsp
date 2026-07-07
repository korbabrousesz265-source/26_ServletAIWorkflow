<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8"/>
    <title>Al Workflow</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden;
            background: radial-gradient(circle at 50% 52%, #1a4cc0 0%, #0a2480 55%, #050c2a 100%);
            font-family: 'Microsoft YaHei', sans-serif; }
        .stage { position: fixed; inset: 0; width: 100vw; height: 100vh; z-index: 10; overflow: hidden; }
        .stars-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1; }
        .star-bg { position: absolute; background: #fff; border-radius: 50%; animation: twinkle 4s infinite ease-in-out; }
        @keyframes twinkle { 0%, 100% { opacity: 0.1; } 50% { opacity: 1; } }
        .canvas-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 2; }

        .frame-wrap { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 5; pointer-events: none; }
        .corner-svg { position: absolute; z-index: 6; pointer-events: none; }
        .corner-svg.tl { top: 10px; left: 10px; }
        .corner-svg.tr { top: 10px; right: 10px; }
        .corner-svg.bl { bottom: 10px; left: 10px; }
        .corner-svg.br { bottom: 10px; right: 10px; }

        .form-panel {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 4;
            display: flex; flex-direction: column;
            padding: 80px 0 80px 90px;
            background: linear-gradient(90deg,
            rgba(12,36,96,0.72) 0%,
            rgba(12,36,96,0.55) 20%,
            rgba(12,36,96,0.25) 45%,
            rgba(12,36,96,0.05) 75%,
            rgba(12,36,96,0) 100%);
        }
        .title { font-size: 30px; font-weight: bold; color: #a7ecff; margin-bottom: 44px; letter-spacing: 6px;
            text-shadow: 0 0 18px rgba(160,230,255,0.7); }
        .fl { display: block; color: rgba(240,250,255,0.95); font-size: 15px; margin-bottom: 8px; font-weight: 600; }
        .fi { width: 360px; padding: 13px 16px;
            background: rgba(10,30,75,0.72); border: 1px solid rgba(140,210,245,0.4);
            border-radius: 2px; color: #fff; font-size: 15px; outline: none; transition: all 0.3s; }
        .fi:focus { border-color: #a7ecff; box-shadow: 0 0 16px rgba(160,230,255,0.4); }
        .fi::placeholder { color: rgba(255,255,255,0.4); }
        .fg { margin-bottom: 20px; }
        .cb { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; width: 360px; }
        .cbl { display: flex; align-items: center; color: rgba(230,242,255,0.85); font-size: 14px; }
        .cbl input { margin-right: 8px; width: 14px; height: 14px; accent-color: #a7ecff; }
        .flk { color: rgba(230,242,255,0.85); text-decoration: none; font-size: 14px;
            border-bottom: 1px solid rgba(200,222,240,0.5); }
        .flk:hover { color: #a7ecff; }
        .lb { width: 360px; padding: 14px;
            background: linear-gradient(90deg, #69d0f0, #3aa8d8);
            border: none; border-radius: 2px; color: #fff; font-size: 16px; font-weight: bold;
            letter-spacing: 2px; cursor: pointer;
            box-shadow: 0 4px 22px rgba(90,210,240,0.55); }
        .lb:hover { transform: translateY(-2px); box-shadow: 0 8px 32px rgba(90,210,240,0.75); }
        .em { background: rgba(255,87,87,0.15); border: 1px solid rgba(255,87,87,0.3);
            border-radius: 2px; padding: 10px 14px; margin-bottom: 18px; color: #ff9b9b;
            font-size: 13px; width: 360px; }
    </style>
</head>
<body>
<div class="stars-bg" id="starsBg"></div>
<div class="stage">
    <canvas id="bgCanvas" class="canvas-bg"></canvas>
    <!-- 四个角六边形科技框 -->
    <svg class="corner-svg tl" width="110" height="110" viewBox="0 0 110 110">
        <path d="M8 90 L8 10 L90 10" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <path d="M18 80 L18 18 L82 18" fill="none" stroke="#80c0ff" stroke-width="1" stroke-opacity="0.5"/>
        <path d="M8 90 L16 90 L16 16 L82 16 L82 10" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <line x1="8" y1="16" x2="16" y2="16" stroke="#a7ecff" stroke-width="2" stroke-opacity="0.6"/>
    </svg>
    <svg class="corner-svg tr" width="110" height="110" viewBox="0 0 110 110">
        <path d="M20 10 L102 10 L102 90" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <path d="M28 18 L92 18 L92 82" fill="none" stroke="#80c0ff" stroke-width="1" stroke-opacity="0.5"/>
        <path d="M20 10 L20 18 L92 18 L92 82 L102 82 L102 10" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <line x1="92" y1="10" x2="92" y2="18" stroke="#a7ecff" stroke-width="2" stroke-opacity="0.6"/>
    </svg>
    <svg class="corner-svg bl" width="110" height="110" viewBox="0 0 110 110">
        <path d="M8 20 L8 102 L90 102" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <path d="M18 28 L18 92 L82 92" fill="none" stroke="#80c0ff" stroke-width="1" stroke-opacity="0.5"/>
        <path d="M8 20 L16 20 L16 92 L82 92 L82 102" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <line x1="8" y1="92" x2="16" y2="92" stroke="#a7ecff" stroke-width="2" stroke-opacity="0.6"/>
    </svg>
    <svg class="corner-svg br" width="110" height="110" viewBox="0 0 110 110">
        <path d="M20 102 L102 102 L102 20" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <path d="M28 92 L92 92 L92 28" fill="none" stroke="#80c0ff" stroke-width="1" stroke-opacity="0.5"/>
        <path d="M20 102 L20 92 L92 92 L92 28 L102 28 L102 102" fill="none" stroke="#a7ecff" stroke-width="2.2" stroke-opacity="0.85"/>
        <line x1="92" y1="102" x2="92" y2="92" stroke="#a7ecff" stroke-width="2" stroke-opacity="0.6"/>
    </svg>

    <div class="form-panel">
        <h1 class="title">Al Workflow</h1>
        <form action="login" method="post" autocomplete="off">
            <c:if test="${not empty msg}">
                <div class="em">✕ ${msg}<c:remove var="msg" scope="session"/></div>
            </c:if>
            <div class="fg"><label class="fl">用户名</label><input class="fi" type="text" name="username" placeholder="请输入您的用户名" required></div>
            <div class="fg"><label class="fl">密码</label><input class="fi" type="password" name="password" placeholder="请输入您的密码" required></div>
            <div class="cb"><label class="cbl"><input type="checkbox" name="remember"/>记住密码</label><a href="#" class="flk">忘记密码?</a></div>
            <button type="submit" class="lb">点击登录</button>
        </form>
    </div>
</div>

<script>
    (function initStars() {
        var box = document.getElementById('starsBg');
        var palette = [
            { col:'#ffffff', pct:0.45, minS:0.6, maxS:2.4, op:[0.3,1.0] },
            { col:'#cfefff', pct:0.22, minS:0.8, maxS:2.8, op:[0.4,1.0] },
            { col:'#a7ecff', pct:0.15, minS:0.9, maxS:3.2, op:[0.5,1.0] },
            { col:'#ffe8a8', pct:0.10, minS:0.8, maxS:2.2, op:[0.4,0.95] },
            { col:'#ffd2f0', pct:0.05, minS:0.7, maxS:1.8, op:[0.35,0.9] },
            { col:'#e4c8ff', pct:0.03, minS:0.7, maxS:2.0, op:[0.3,0.85] }
        ];
        var total = 1500;
        for (var i=0;i<total;i++) {
            var r = Math.random(), cum=0, pick=palette[0];
            for (var k=0;k<palette.length;k++) { cum += palette[k].pct; if (r<=cum){pick=palette[k];break;} }
            var size = Math.random()*(pick.maxS-pick.minS)+pick.minS;
            var op = Math.random()*(pick.op[1]-pick.op[0])+pick.op[0];
            var s = document.createElement('div');
            s.className='star-bg';
            s.style.background=pick.col;
            s.style.width=size+'px';
            s.style.height=size+'px';
            s.style.left=Math.random()*100+'%';
            s.style.top=Math.random()*100+'%';
            s.style.opacity=op;
            s.style.boxShadow='0 0 '+(size*3.0)+'px '+pick.col;
            // 闪烁速度加快，持续时间在0.8~2.8秒之间，更活泼
            s.style.animationDuration=(Math.random()*2 + 0.8)+'s';
            s.style.animationDelay=Math.random()*2+'s';
            box.appendChild(s);
        }
        setInterval(function(){
            if (Math.random()<0.25){
                var m=document.createElement('div');
                m.style.position='fixed';
                m.style.top=(Math.random()*35)+'%';
                m.style.left='-120px';
                m.style.width='180px';
                m.style.height='2px';
                var c1=['rgba(255,255,255,0.95)','rgba(160,230,255,0.85)','rgba(200,220,255,0.8)'];
                var cc=c1[Math.floor(Math.random()*3)];
                m.style.background='linear-gradient(90deg, '+cc+', rgba(220,240,255,0.6), rgba(0,0,0,0))';
                m.style.zIndex='2';
                m.style.transform='rotate('+(20+Math.random()*18)+'deg)';
                m.style.transition='left 1.3s linear, opacity 1.3s linear';
                m.style.opacity='1';
                document.body.appendChild(m);
                requestAnimationFrame(function(){ m.style.left='125%'; m.style.opacity='0'; });
                setTimeout(function(){ if(m.parentNode) m.parentNode.removeChild(m); }, 1800);
            }
        }, 2800);
    })();

    var cv = document.getElementById('bgCanvas'), c = cv.getContext('2d');
    var W=0, H=0, cx=0, cy=0, R=0;

    var canvasStars = [];
    function generateCanvasStars() {
        canvasStars = [];
        var starCount = 2500;
        var colors = [
            'rgba(255,255,255,',
            'rgba(200,230,255,',
            'rgba(255,240,200,',
            'rgba(255,200,220,',
            'rgba(220,200,255,'
        ];
        for (var i = 0; i < starCount; i++) {
            var x = Math.random() * W;
            var y = Math.random() * H;
            var radius = Math.random() * 2.2 + 0.5;
            var colorIndex = Math.floor(Math.random() * colors.length);
            var baseAlpha = Math.random() * 0.8 + 0.2;
            // 存储基础颜色（不带透明度）和随机相位，用于动态闪烁
            canvasStars.push({
                x: x, y: y, r: radius,
                baseColor: colors[colorIndex],
                baseAlpha: baseAlpha,
                phase: Math.random() * Math.PI * 2
            });
        }
    }
    function drawCanvasStars(t) {
        canvasStars.forEach(function(s) {
            // 闪烁因子，随时间正弦变化，范围0.3~1.0，保留最低亮度避免完全消失
            var flicker = 0.35 + 0.65 * Math.abs(Math.sin(t * 6 + s.phase));
            var alpha = Math.max(0.1, Math.min(1, s.baseAlpha * flicker));
            var color = s.baseColor + alpha + ')';
            c.fillStyle = color;
            c.beginPath();
            c.arc(s.x, s.y, s.r, 0, Math.PI * 2);
            c.fill();
            if (s.r > 1.5) {
                c.shadowColor = s.baseColor + '0.6)';
                c.shadowBlur = s.r * 3;
                c.fill();
                c.shadowBlur = 0;
            }
        });
    }

    function setup() {
        W = window.innerWidth; H = window.innerHeight;
        cv.width = W; cv.height = H;
        cx = W * 0.72; cy = H * 0.52;
        R = Math.min(W * 0.08, H * 0.16);
        generateCanvasStars();
    }
    setup();
    window.addEventListener('resize', setup);

    var lands = [
        {name:'eurasia', pts:[
                [50,-130],[55,-120],[58,-105],[60,-90],[60,-70],[58,-55],[55,-40],[52,-25],[50,-15],[48,-8],
                [45,0],[42,8],[40,15],[38,20],[35,25],[33,32],[32,40],[31,48],[30,55],[30,62],[31,70],[32,78],[34,85],[36,92],[40,98],[45,103],[50,108],[55,112],[60,115],[62,118],
                [64,122],[65,128],[64,135],[62,142],[58,148],[54,153],[50,158],[45,162],[40,168],[35,172],[30,176],[25,180],[20,-178],[15,-172],[10,-165],[5,-155],[0,-145],[-5,-138],[-10,-132],[-15,-128],[-20,-125],[-25,-123],[-30,-121],[-35,-120],[-40,-119]
            ]},
        {name:'africa', pts:[
                [38,-8],[36,-10],[33,-12],[30,-13],[27,-14],[23,-14],[20,-13],[17,-12],[14,-9],[11,-5],[9,0],[8,5],[7,12],[6,18],[5,25],[4,32],[3,38],[2,45],[0,52],[-2,58],[-5,62],[-8,64],[-12,64],[-16,60],[-20,55],[-24,50],[-28,44],[-31,38],[-34,32],[-36,26],[-38,20],[-39,14],[-38,8],[-36,4],[-33,0],[-30,-4],[-26,-7],[-22,-9],[-18,-10],[-14,-10],[-10,-10],[-5,-10],[0,-10],[5,-10],[10,-10],[15,-10],[20,-10],[25,-10],[30,-10],[35,-10]
            ]},
        {name:'namerica', pts:[
                [72,-170],[74,-160],[75,-145],[75,-130],[74,-118],[72,-108],[68,-100],[64,-95],[60,-92],[55,-90],[50,-89],[45,-90],[42,-93],[40,-97],[38,-102],[36,-107],[34,-112],[32,-116],[30,-120],[28,-123],[26,-126],[24,-128],[22,-130],[20,-131],[18,-132],[15,-133],[12,-133],[9,-132],[6,-130],[3,-127],[0,-124],[-2,-120],[-4,-116],[-6,-112],[-8,-108],[-10,-104],[-12,-100],[-14,-96],[-16,-92],[-18,-88],[-20,-84],[-22,-80],[-24,-76],[-26,-72],[-28,-68],[-30,-64],[-32,-60],[-34,-56],[-36,-52],[-38,-48],[-40,-44],[-42,-40],[-44,-36],[-46,-32],[-48,-28],[-50,-24],[-52,-20],[-54,-16],[-56,-12],[-58,-8],[-60,-4],[-62,0],[-64,4],[-66,8],[-68,12],[-70,16],[-72,20]
            ]},
        {name:'samerica', pts:[
                [12,-80],[15,-76],[18,-72],[21,-68],[24,-63],[27,-58],[30,-53],[33,-48],[36,-43],[39,-38],[42,-33],[45,-28],[48,-23],[51,-18],[54,-13],[56,-8],[58,-3],[59,2],[58,7],[56,11],[54,14],[51,17],[48,19],[45,21],[42,23],[39,25],[36,27],[33,29],[30,31],[27,33],[24,35],[21,37],[18,39],[15,41],[12,43],[9,45],[6,47],[3,49],[0,51],[-3,53],[-6,55],[-9,57],[-12,59],[-15,61],[-18,63],[-21,65],[-24,67],[-27,69],[-30,71],[-33,73],[-36,75],[-39,77],[-42,79],[-45,81],[-48,83],[-51,85],[-54,87],[-57,89],[-60,91],[-63,93],[-66,95],[-69,97],[-72,99],[-75,101],[-78,103]
            ]},
        {name:'ozania', pts:[
                [-10,113],[-13,116],[-17,119],[-20,122],[-23,125],[-26,128],[-29,131],[-32,133],[-35,135],[-38,137],[-41,138],[-44,139],[-47,140],[-50,141],[-53,142],[-56,143],[-59,144],[-62,145],[-65,146],[-68,147],[-71,148],[-74,149],[-77,150]
            ]}
    ];

    var angle = 0;

    function drawBackdrop(t) {
        var bg = c.createLinearGradient(0, 0, 0, H);
        bg.addColorStop(0, '#020618');
        bg.addColorStop(0.3, '#081a4a');
        bg.addColorStop(0.55,'#0c2b6e');
        bg.addColorStop(0.78,'#071840');
        bg.addColorStop(1, '#020612');
        c.fillStyle = bg; c.fillRect(0,0,W,H);

        // 银河大星云带
        var milky = c.createRadialGradient(W*0.25, H*0.52, 20, W*0.25, H*0.52, Math.max(W,H)*1.2);
        milky.addColorStop(0, 'rgba(220,130,255,0.55)');
        milky.addColorStop(0.10,'rgba(190,100,230,0.40)');
        milky.addColorStop(0.25,'rgba(150,90,210,0.25)');
        milky.addColorStop(0.45,'rgba(110,110,205,0.12)');
        milky.addColorStop(0.7,'rgba(70,90,180,0.04)');
        milky.addColorStop(1,'rgba(0,0,0,0)');
        c.save();
        c.translate(W*0.25, H*0.52);
        c.rotate(-0.38);
        c.scale(3.2, 0.42);
        c.fillStyle = milky;
        c.fillRect(-Math.max(W,H), -Math.max(W,H), Math.max(W,H)*2, Math.max(W,H)*2);
        c.restore();

        var milky2 = c.createRadialGradient(W*0.25, H*0.52, 20, W*0.25, H*0.52, Math.max(W,H)*0.9);
        milky2.addColorStop(0,'rgba(150,220,255,0.48)');
        milky2.addColorStop(0.18,'rgba(120,180,235,0.28)');
        milky2.addColorStop(0.4,'rgba(90,130,210,0.08)');
        milky2.addColorStop(1,'rgba(0,0,0,0)');
        c.save();
        c.translate(W*0.25, H*0.52);
        c.rotate(-0.38);
        c.scale(3.2, 0.42);
        c.fillStyle = milky2;
        c.fillRect(-Math.max(W,H), -Math.max(W,H), Math.max(W,H)*2, Math.max(W,H)*2);
        c.restore();

        // 绚丽星云
        var neb1 = c.createRadialGradient(W*0.15, H*0.2, 10, W*0.15, H*0.2, R*7.0);
        neb1.addColorStop(0, 'rgba(255, 120, 180, 0.65)');
        neb1.addColorStop(0.2, 'rgba(200, 80, 160, 0.4)');
        neb1.addColorStop(0.5, 'rgba(130, 50, 140, 0.15)');
        neb1.addColorStop(1, 'rgba(0,0,0,0)');
        c.fillStyle = neb1; c.fillRect(0,0,W,H);

        var neb2 = c.createRadialGradient(W*0.85, H*0.75, 10, W*0.85, H*0.75, R*6.4);
        neb2.addColorStop(0, 'rgba(100, 230, 200, 0.55)');
        neb2.addColorStop(0.3, 'rgba(70, 180, 180, 0.3)');
        neb2.addColorStop(0.6, 'rgba(40, 100, 140, 0.1)');
        neb2.addColorStop(1, 'rgba(0,0,0,0)');
        c.fillStyle = neb2; c.fillRect(0,0,W,H);

        var neb3 = c.createRadialGradient(cx - R*0.5, cy - R*1.8, 10, cx - R*0.5, cy - R*1.8, R*5.6);
        neb3.addColorStop(0, 'rgba(255, 210, 120, 0.5)');
        neb3.addColorStop(0.4, 'rgba(200, 150, 80, 0.2)');
        neb3.addColorStop(1, 'rgba(0,0,0,0)');
        c.fillStyle = neb3; c.fillRect(0,0,W,H);

        var neb4 = c.createRadialGradient(cx + R*2.5, cy + R*0.8, 10, cx + R*2.5, cy + R*0.8, R*5.0);
        neb4.addColorStop(0, 'rgba(170, 100, 230, 0.6)');
        neb4.addColorStop(0.5, 'rgba(120, 60, 180, 0.2)');
        neb4.addColorStop(1, 'rgba(0,0,0,0)');
        c.fillStyle = neb4; c.fillRect(0,0,W,H);

        // 极光
        var aur1 = c.createRadialGradient(cx + W*0.18, cy - H*0.32, 10, cx + W*0.18, cy - H*0.32, Math.max(W,H)*0.7);
        aur1.addColorStop(0,'rgba(220,130,255,0.78)');
        aur1.addColorStop(0.12,'rgba(190,100,230,0.55)');
        aur1.addColorStop(0.3,'rgba(150,90,210,0.28)');
        aur1.addColorStop(0.6,'rgba(110,100,200,0.10)');
        aur1.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = aur1; c.fillRect(0,0,W,H);

        var aur2 = c.createRadialGradient(cx + W*0.32, cy - H*0.08, 10, cx + W*0.32, cy - H*0.08, Math.max(W,H)*0.6);
        aur2.addColorStop(0,'rgba(140,190,255,0.70)');
        aur2.addColorStop(0.12,'rgba(100,150,235,0.48)');
        aur2.addColorStop(0.3,'rgba(80,120,215,0.20)');
        aur2.addColorStop(0.6,'rgba(70,95,190,0.05)');
        aur2.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = aur2; c.fillRect(0,0,W,H);

        // 中心蓝晕
        var core = c.createRadialGradient(cx, cy, 10, cx, cy, R*10.0);
        core.addColorStop(0,'rgba(150,240,255,0.60)');
        core.addColorStop(0.12,'rgba(120,210,250,0.42)');
        core.addColorStop(0.30,'rgba(80,160,230,0.18)');
        core.addColorStop(0.55,'rgba(50,110,200,0.05)');
        core.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = core; c.fillRect(0,0,W,H);

        var nebR = c.createRadialGradient(cx + R*2.8, cy + R*1.8, 10, cx + R*2.8, cy + R*1.8, R*6.4);
        nebR.addColorStop(0,'rgba(180,210,255,0.60)');
        nebR.addColorStop(0.2,'rgba(140,175,235,0.32)');
        nebR.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = nebR; c.fillRect(0,0,W,H);

        var nebL = c.createRadialGradient(W*0.10, H*0.22, 10, W*0.10, H*0.22, R*5.6);
        nebL.addColorStop(0,'rgba(210,165,255,0.58)');
        nebL.addColorStop(0.28,'rgba(150,120,225,0.25)');
        nebL.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = nebL; c.fillRect(0,0,W,H);

        var nebBL = c.createRadialGradient(W*0.18, H*0.85, 10, W*0.18, H*0.85, R*4.8);
        nebBL.addColorStop(0,'rgba(175,150,240,0.45)');
        nebBL.addColorStop(0.4,'rgba(120,95,205,0.15)');
        nebBL.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = nebBL; c.fillRect(0,0,W,H);

        var nebUR = c.createRadialGradient(W*0.82, H*0.15, 10, W*0.82, H*0.15, R*3.6);
        nebUR.addColorStop(0,'rgba(210,170,255,0.48)');
        nebUR.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = nebUR; c.fillRect(0,0,W,H);

        drawCanvasStars(t);
    }

    function drawOrbitRings(t) {
        var defs = [
            { r: 3.4, b: 0.28, lw: 1.5, col:'rgba(240,255,255,0.55)', dash: 0, n: 18, sp: 0.05 },
            { r: 3.0, b: 0.30, lw: 1.3, col:'rgba(230,250,255,0.52)', dash: 3, n: 14, sp: 0.07 },
            { r: 2.65, b: 0.32, lw: 1.6, col:'rgba(245,255,255,0.62)', dash: 0, n: 16, sp: 0.09 },
            { r: 2.32, b: 0.34, lw: 1.4, col:'rgba(235,250,255,0.60)', dash: 3, n: 12, sp: 0.12 },
            { r: 2.02, b: 0.34, lw: 1.6, col:'rgba(245,255,255,0.70)', dash: 0, n: 16, sp: 0.15 },
            { r: 1.76, b: 0.32, lw: 1.5, col:'rgba(240,252,255,0.72)', dash: 0, n: 14, sp: 0.18 },
            { r: 1.54, b: 0.30, lw: 1.4, col:'rgba(230,248,255,0.68)', dash: 2, n: 12, sp: 0.22 },
            { r: 1.35, b: 0.27, lw: 1.3, col:'rgba(220,242,255,0.62)', dash: 0, n: 10, sp: 0.26 },
            { r: 1.20, b: 0.23, lw: 1.2, col:'rgba(210,238,255,0.56)', dash: 0, n: 10, sp: 0.30 }
        ];
        var ang = t * 0.07;
        // 卫星光点移动速度加快（约为原来的3倍）
        var fastT = t * 3.0;
        for (var i=0; i<defs.length; i++) {
            var bw = R * defs[i].r;
            var bh = R * defs[i].b * defs[i].r;
            c.save();
            c.translate(cx, cy);
            c.rotate(ang + i*0.04);
            c.strokeStyle = defs[i].col;
            c.lineWidth = defs[i].lw;
            c.shadowColor = defs[i].col;
            c.shadowBlur = 5;
            if (defs[i].dash > 0) c.setLineDash([defs[i].dash, defs[i].dash+2]);
            c.beginPath();
            c.ellipse(0, 0, bw, bh, 0, 0, Math.PI*2);
            c.stroke();
            c.setLineDash([]);
            c.shadowBlur = 0;

            var orbitPh = fastT * defs[i].sp + i * 0.55;
            for (var j=0; j<defs[i].n; j++) {
                var base = (Math.PI*2 / defs[i].n) * j + orbitPh;
                var dx = Math.cos(base) * bw;
                var dy = Math.sin(base) * bh;
                var col = (j%2===0) ? '#98f8ff' : '#b6f5d8';
                c.fillStyle = col;
                c.shadowColor = col;
                c.shadowBlur = 12;
                c.beginPath();
                c.arc(dx, dy, 3.0, 0, Math.PI*2);
                c.fill();
                for (var k=1;k<=2;k++) {
                    var tB = base - k*0.32;
                    var tdx = Math.cos(tB)*bw, tdy = Math.sin(tB)*bh;
                    var ak = 0.30 - k*0.12;
                    if (ak<=0) continue;
                    var tc = (j%2===0) ? 'rgba(152,248,255,'+ak+')':'rgba(182,245,216,'+ak+')';
                    c.fillStyle = tc;
                    c.shadowBlur = 0;
                    c.beginPath(); c.arc(tdx, tdy, 3.0-k*0.7, 0, Math.PI*2); c.fill();
                }
                c.shadowBlur = 0;
            }
            c.restore();
        }
    }

    function drawGlobe(t) {
        var glows = [
            { r: 4.0, c:'rgba(160,220,255,0.18)' },
            { r: 3.2, c:'rgba(180,225,255,0.25)' },
            { r: 2.6, c:'rgba(200,235,255,0.38)' },
            { r: 2.0, c:'rgba(220,245,255,0.55)' },
            { r: 1.6, c:'rgba(235,252,255,0.70)' },
            { r: 1.3, c:'rgba(245,255,255,0.85)' }
        ];
        glows.forEach(function(g){
            var gg = c.createRadialGradient(cx,cy,R*0.95,cx,cy,R*g.r);
            gg.addColorStop(0, g.c);
            gg.addColorStop(0.55, g.c.replace(/[\d.]+\)$/g, '0.10)'));
            gg.addColorStop(1, 'rgba(0,0,0,0)');
            c.fillStyle = gg;
            c.beginPath(); c.arc(cx,cy,R*g.r,0,Math.PI*2); c.fill();
        });

        var ocean = c.createRadialGradient(cx - R*0.4, cy - R*0.42, R*0.02, cx, cy, R);
        ocean.addColorStop(0, '#eafaff');
        ocean.addColorStop(0.08,'#d8f4ff');
        ocean.addColorStop(0.18,'#b3e2f5');
        ocean.addColorStop(0.32,'#88c8e8');
        ocean.addColorStop(0.50,'#5aa0d0');
        ocean.addColorStop(0.68,'#2e70a8');
        ocean.addColorStop(0.82,'#144585');
        ocean.addColorStop(0.95,'#0a2a66');
        ocean.addColorStop(1, '#1a4090');
        c.fillStyle = ocean;
        c.beginPath(); c.arc(cx,cy,R,0,Math.PI*2); c.fill();

        var hl = c.createRadialGradient(cx - R*0.42, cy - R*0.45, R*0.02, cx - R*0.42, cy - R*0.45, R*0.75);
        hl.addColorStop(0,'rgba(255,255,255,0.88)');
        hl.addColorStop(0.12,'rgba(255,255,255,0.55)');
        hl.addColorStop(0.35,'rgba(255,255,255,0.15)');
        hl.addColorStop(0.6,'rgba(255,255,255,0.02)');
        hl.addColorStop(1,'rgba(255,255,255,0)');
        c.fillStyle = hl; c.beginPath(); c.arc(cx,cy,R,0,Math.PI*2); c.fill();

        var sh = c.createRadialGradient(cx + R*0.52, cy + R*0.55, R*0.02, cx + R*0.52, cy + R*0.55, R*0.75);
        sh.addColorStop(0,'rgba(0,0,0,0.55)');
        sh.addColorStop(0.3,'rgba(0,0,0,0.28)');
        sh.addColorStop(0.65,'rgba(0,0,0,0.05)');
        sh.addColorStop(1,'rgba(0,0,0,0)');
        c.fillStyle = sh; c.beginPath(); c.arc(cx,cy,R,0,Math.PI*2); c.fill();

        var edge = c.createRadialGradient(cx, cy, R*0.90, cx, cy, R*1.6);
        edge.addColorStop(0,'rgba(25,65,160,0.90)');
        edge.addColorStop(0.25,'rgba(25,65,160,0.60)');
        edge.addColorStop(0.55,'rgba(30,75,180,0.28)');
        edge.addColorStop(0.85,'rgba(35,90,200,0.06)');
        edge.addColorStop(1,'rgba(0,0,0,0)');
        c.globalCompositeOperation = 'lighter';
        c.fillStyle = edge; c.beginPath(); c.arc(cx,cy,R*1.6,0,Math.PI*2); c.fill();
        c.globalCompositeOperation = 'source-over';

        c.save();
        c.beginPath(); c.arc(cx,cy,R,0,Math.PI*2); c.clip();

        var centers = [];
        lands.forEach(function(L){
            var pts3 = [];
            for (var i=0;i<L.pts.length;i++) {
                var p = L.pts[i];
                var lat = p[0]*Math.PI/180, lon = p[1]*Math.PI/180 + t;
                pts3.push({ x: Math.cos(lat)*Math.sin(lon), y: Math.sin(lat), z: Math.cos(lat)*Math.cos(lon) });
            }
            var vis = [];
            for (var i=0;i<pts3.length;i++) {
                var pp = pts3[i];
                var prev = pts3[(i-1+pts3.length)%pts3.length];
                var next = pts3[(i+1)%pts3.length];
                if (pp.z>0 || prev.z>0 || next.z>0) vis.push(pp);
            }
            if (vis.length < 4) return;

            var ctrZ = 0;
            for (var i=0;i<vis.length;i++) ctrZ += vis[i].z;
            ctrZ /= vis.length;
            var shade = Math.max(0.45, Math.min(1.0, 0.55 + ctrZ * 0.5));
            var rC = Math.round(45 + 45*shade);
            var gC = Math.round(75 + 55*shade);
            var bC = Math.round(140 + 65*shade);
            c.fillStyle = 'rgba('+rC+','+gC+','+bC+',0.75)';

            c.beginPath();
            for (var i=0;i<vis.length;i++) {
                var px = cx + vis[i].x*R, py = cy - vis[i].y*R;
                if (i===0) c.moveTo(px,py); else c.lineTo(px,py);
            }
            c.closePath();
            c.fill();
            c.strokeStyle = 'rgba(160,225,250,0.55)';
            c.lineWidth = 0.55;
            c.shadowColor = 'rgba(160,225,250,0.9)';
            c.shadowBlur = 3;
            c.stroke();
            c.shadowBlur = 0;

            var midIdx = Math.floor(L.pts.length/2);
            var m = L.pts[midIdx];
            var mLat = m[0]*Math.PI/180, mLon = m[1]*Math.PI/180 + t;
            var mx = Math.cos(mLat)*Math.sin(mLon);
            var my = Math.sin(mLat);
            var mz = Math.cos(mLat)*Math.cos(mLon);
            if (mz > 0.15) centers.push({x: cx + mx*R, y: cy - my*R});
        });

        c.strokeStyle = 'rgba(245,252,255,0.42)';
        c.lineWidth = 0.45;
        c.shadowColor = 'rgba(200,240,255,0.6)';
        c.shadowBlur = 2;
        for (var i=0;i<centers.length;i++) {
            c.beginPath(); c.moveTo(cx, cy); c.lineTo(centers[i].x, centers[i].y); c.stroke();
            for (var j=i+1;j<centers.length;j++) {
                c.beginPath(); c.moveTo(centers[i].x, centers[i].y); c.lineTo(centers[j].x, centers[j].y); c.stroke();
            }
        }
        c.shadowBlur = 0;
        centers.forEach(function(p){
            c.fillStyle = '#ccffff';
            c.shadowColor = '#ccffff';
            c.shadowBlur = 10;
            c.beginPath(); c.arc(p.x, p.y, 2.5, 0, Math.PI*2); c.fill();
            c.shadowBlur = 0;
        });

        c.strokeStyle = 'rgba(225,248,255,0.22)';
        c.lineWidth = 0.4;
        for (var lat=-72; lat<=72; lat+=16) {
            c.beginPath(); var f=true;
            for (var lon=-180; lon<=180; lon+=4) {
                var latR=lat*Math.PI/180, lonR=lon*Math.PI/180+t;
                var x=Math.cos(latR)*Math.sin(lonR), z=Math.cos(latR)*Math.cos(lonR);
                if (z>0) { var px=cx+x*R, py=cy-Math.sin(latR)*R; if (f){c.moveTo(px,py);f=false;}else c.lineTo(px,py);} else f=true;
            }
            c.stroke();
        }
        for (var lon=-180; lon<=180; lon+=24) {
            c.beginPath(); var f2=true;
            for (var lat=-82; lat<=82; lat+=4) {
                var latR=lat*Math.PI/180, lonR=lon*Math.PI/180+t;
                var x=Math.cos(latR)*Math.sin(lonR), z=Math.cos(latR)*Math.cos(lonR);
                if (z>0) { var px=cx+x*R, py=cy-Math.sin(latR)*R; if (f2){c.moveTo(px,py);f2=false;}else c.lineTo(px,py);} else f2=true;
            }
            c.stroke();
        }

        c.restore();
        var ee = c.createRadialGradient(cx,cy,R*0.92,cx,cy,R*1.18);
        ee.addColorStop(0,'rgba(210,240,255,0.55)');
        ee.addColorStop(0.55,'rgba(140,200,255,0.15)');
        ee.addColorStop(1,'rgba(0,0,0,0)');
        c.globalCompositeOperation='lighter';
        c.fillStyle=ee; c.beginPath(); c.arc(cx,cy,R*1.18,0,Math.PI*2); c.fill();
        c.globalCompositeOperation='source-over';
    }

    function drawExtras(t) {
        c.strokeStyle = 'rgba(248,255,255,0.55)';
        c.lineWidth = 0.7;
        c.shadowColor = 'rgba(220,245,255,0.7)';
        c.shadowBlur = 3;
        for (var k=-3; k<=3; k++) {
            c.beginPath();
            c.moveTo(cx - R*2.8, cy + R*2.2 + k*28);
            c.lineTo(cx + R*3.5, cy - R*0.6 + k*15);
            c.stroke();
        }

        c.strokeStyle = 'rgba(255,140,190,0.65)'; c.lineWidth = 0.6;
        c.beginPath(); c.moveTo(cx - R*1.0, cy + R*1.1); c.lineTo(cx + R*3.5, cy - R*0.4); c.stroke();
        c.strokeStyle = 'rgba(255,210,110,0.60)'; c.lineWidth = 0.5;
        c.beginPath(); c.moveTo(cx - R*1.4, cy + R*0.8); c.lineTo(cx + R*3.6, cy - R*0.2); c.stroke();

        var ex = cx + R*2.6, ey = cy + R*0.9;
        c.lineWidth = 0.9;
        for (var k=0;k<10;k++) {
            var rr = R*0.35 + k*R*0.18;
            c.setLineDash([7,5]);
            var a = 0.10 + k*0.03;
            c.strokeStyle = 'rgba(220,245,255,'+a+')';
            c.shadowColor = 'rgba(220,245,255,0.4)';
            c.shadowBlur = 4;
            c.beginPath();
            c.arc(ex, ey, rr, Math.PI*1.1, Math.PI*1.92);
            c.stroke();
        }
        c.setLineDash([]);

        c.strokeStyle = 'rgba(220,245,255,0.22)';
        c.lineWidth = 0.4;
        for (var a=10; a<=170; a+=4) {
            var ag=a*Math.PI/180;
            c.beginPath();
            c.moveTo(cx + Math.cos(ag)*R*1.03, cy + Math.sin(ag)*R*1.03);
            c.lineTo(cx + Math.cos(ag)*R*3.5, cy + Math.sin(ag)*R*3.5);
            c.stroke();
        }
        for (var a=195; a<=300; a+=4) {
            var ag=a*Math.PI/180;
            c.beginPath();
            c.moveTo(cx + Math.cos(ag)*R*1.03, cy + Math.sin(ag)*R*1.03);
            c.lineTo(cx + Math.cos(ag)*R*3.7, cy + Math.sin(ag)*R*3.7);
            c.stroke();
        }

        var pts = [
            {x: cx - R*1.4, y: cy + R*0.6, c:'#88f8ff', s:4.2},
            {x: cx - R*1.1, y: cy + R*1.0, c:'#98f5d0', s:3.8},
            {x: cx - R*0.7, y: cy + R*0.35, c:'#88f8ff', s:4.0},
            {x: ex - R*0.1, y: ey - R*0.75, c:'#98f5d0', s:4.2},
            {x: ex - R*0.5, y: ey + R*0.15, c:'#88f8ff', s:3.8},
            {x: ex - R*0.95, y: ey + R*0.95, c:'#98f5d0', s:3.6},
            {x: ex - R*1.4, y: ey + R*0.4, c:'#88f8ff', s:4.2},
            {x: ex - R*1.85, y: ey + R*1.1, c:'#98f5d0', s:3.2},
            {x: cx + R*2.7, y: cy + R*1.9, c:'#88f8ff', s:3.8},
            {x: cx + R*3.2, y: cy + R*2.6, c:'#98f5d0', s:3.2},
            {x: cx - R*2.8, y: cy + R*2.7, c:'#88f8ff', s:3.4},
            {x: cx - R*1.9, y: cy + R*1.9, c:'#98f5d0', s:3.0},
            {x: W*0.13 + 60, y: H*0.82, c:'#88f8ff', s:3.6},
            {x: W*0.13 + 100, y: H*0.83, c:'#98f5d0', s:2.8},
            {x: W*0.13 + 140, y: H*0.82, c:'#88f8ff', s:3.4},
            {x: W*0.13 + 20, y: H*0.83, c:'#98f5d0', s:3.0}
        ];
        pts.forEach(function(p){
            c.fillStyle = p.c;
            c.shadowColor = p.c;
            c.shadowBlur = 14;
            c.beginPath(); c.arc(p.x, p.y, p.s, 0, Math.PI*2); c.fill();
            c.shadowBlur = 0;
        });

        c.strokeStyle = 'rgba(220,245,255,0.45)';
        c.lineWidth = 0.6;
        c.setLineDash([5,4]);
        var bx = W*0.13 + 80, by = H*0.83;
        c.beginPath();
        c.arc(bx, by+20, 60, Math.PI*1.2, Math.PI*1.8);
        c.stroke();
        c.setLineDash([]);
        c.shadowBlur = 0;
    }

    function tick() {
        c.clearRect(0,0,W,H);
        angle += 0.0035;
        try {
            drawBackdrop(angle);
            drawOrbitRings(angle);
            drawExtras(angle);
            drawGlobe(angle);
        } catch(e) {}
        requestAnimationFrame(tick);
    }
    tick();
</script>
</body>
</html>