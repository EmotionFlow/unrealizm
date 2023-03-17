<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteUserC results = new DeleteUserC();
results.GetParam(request);

int nRtn = 0;
if( checkLogin.m_bLogin && results.m_nUserId == checkLogin.m_nUserId ) {
	nRtn = results.GetResults(checkLogin, request);
}
%>{"result":<%=nRtn%>}
