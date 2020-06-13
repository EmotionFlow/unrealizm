<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
{
	CheckLogin cCheckLogin = new CheckLogin(request, response);
	if(cCheckLogin.m_bLogin) {
		response.sendRedirect("/MyHomePcV.jsp");
	}
}
%>
<%@include file="/StartPoipikuPcV.jsp"%>
