<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteContentC results = new DeleteContentC();
results.GetParam(request);

boolean bRtn = false;
if( checkLogin.m_bLogin && results.m_nUserId == checkLogin.m_nUserId ) {
	bRtn = results.GetResults(request.getServletContext());
}
%><%=bRtn%>