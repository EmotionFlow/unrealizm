<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	boolean apiResult = false;
	CheckLogin checkLogin = new CheckLogin(request, response);
	SendUserWaveReplyC results = new SendUserWaveReplyC();
	if (checkLogin.m_bLogin) {
		results.getParam(request);
		apiResult = results.getResults(checkLogin, _TEX);
	}
%>{"result" : <%=(apiResult)?Common.API_OK:Common.API_NG%>, "message" : "<%=results.resultMessage%>"}