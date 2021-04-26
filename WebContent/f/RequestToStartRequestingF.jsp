<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

RequestToStartRequestingC c = new RequestToStartRequestingC();
c.getParam(request);
boolean result = c.getResults(checkLogin);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"result_detail":<%=c.resultDetail.getCode()%>,"error_code":<%=c.errorKind.getCode()%>}
