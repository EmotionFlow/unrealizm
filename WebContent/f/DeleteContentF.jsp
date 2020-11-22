<%@page import="java.util.Locale.Category"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteContentC cResults = new DeleteContentC();
cResults.GetParam(request);

boolean bRtn = false;
if( checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId ) {
	bRtn = cResults.GetResults(request.getServletContext());
}
%><%=bRtn%>