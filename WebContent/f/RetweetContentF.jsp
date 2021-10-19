<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

boolean result;

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

RetweetContentC controller = new RetweetContentC();
controller.getParam(request);
result = controller.getResults(checkLogin);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"error_code":<%=controller.errorKind.getCode()%>,"error_detail_code":<%=controller.errorDetail.getCode()%>}
