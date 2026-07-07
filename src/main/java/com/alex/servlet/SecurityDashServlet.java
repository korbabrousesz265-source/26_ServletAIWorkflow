package com.alex.servlet;

import com.alex.mapper.WfHistoryLogMapper;
import com.alex.utils.MyBatisUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.ibatis.session.SqlSession;

@WebServlet("/security-dash")
public class SecurityDashServlet extends BaseServlet {
    protected String index(HttpServletRequest request, HttpServletResponse response) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            WfHistoryLogMapper logMapper = sqlSession.getMapper(WfHistoryLogMapper.class);

            // 实时聚合全站大盘数据
            request.setAttribute("totalCalls", logMapper.getTotalApiCalls());
            request.setAttribute("totalTokens", logMapper.getTotalTokens());
            request.setAttribute("avgDuration", logMapper.getAvgDuration());

            // 拦截次数可暂时设为硬编码，未来可从 WAF 日志表接入
            request.setAttribute("interceptCount", 0);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "/security-dash.jsp";
    }
}