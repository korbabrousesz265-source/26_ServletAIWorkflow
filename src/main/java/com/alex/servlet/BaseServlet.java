package com.alex.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.lang.reflect.Method;

/**
 * 👑 核心基类：利用反射动态分发请求 + 统一视图解析
 */
public abstract class BaseServlet extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "index";
        }

        try {
            // 1. 利用反射获取对应的业务方法
            Method method = this.getClass().getDeclaredMethod(action, HttpServletRequest.class, HttpServletResponse.class);
            method.setAccessible(true);

            // 2. ⚡【核心升级】调用方法，并接收它的返回值！
            Object returnValue = method.invoke(this, request, response);

            // 3. 🧠 统一视图解析器 (View Resolver)
            if (returnValue != null) {
                String path = String.valueOf(returnValue);

                if (path.startsWith("redirect:")) {
                    // 如果前缀是 redirect: ，执行重定向 (PRG模式)
                    // 例如 "redirect:userServlet?action=index" 变成 "userServlet?action=index"
                    String redirectPath = path.substring("redirect:".length());
                    response.sendRedirect(redirectPath);

                } else if (path.startsWith("forward:")) {
                    // 如果前缀是 forward: ，执行请求转发
                    String forwardPath = path.substring("forward:".length());
                    request.getRequestDispatcher(forwardPath).forward(request, response);

                } else {
                    // 如果没有特殊前缀，默认走请求转发 (最常用的场景)
                    request.getRequestDispatcher(path).forward(request, response);
                }
            }
            // 💡 如果 returnValue 为 null，说明子类自己处理了响应（例如直接 PrintWriter 输出 JSON），基类什么都不做。

        } catch (NoSuchMethodException e) {
            System.err.println("❌ 严重警告：在 " + this.getClass().getSimpleName() + " 中找不到方法 [" + action + "]");
            response.sendError(404, "❌ 非法请求：找不到对应的操作方法");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "❌ 服务器内部反射调用异常");
        }
    }
}