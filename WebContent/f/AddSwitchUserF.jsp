<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

boolean result = false;

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

SwitchUserC controller = new SwitchUserC();
controller.getParam(request);
result = controller.getResults(checkLogin, response);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"error_code":<%=controller.errorKind.getCode()%>}
