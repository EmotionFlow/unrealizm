<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

DeleteUserC cResults = new DeleteUserC();
cResults.GetParam(request);

int nRtn = 0;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	nRtn = cResults.GetResults(cCheckLogin, request.getServletContext());
}
%>{"result":<%=nRtn%>}
