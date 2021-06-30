<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteUserC cResults = new DeleteUserC();
cResults.GetParam(request);

int nRtn = 0;
if( checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId ) {
	nRtn = cResults.GetResults(checkLogin, request);
}
%>{"result":<%=nRtn%>}
