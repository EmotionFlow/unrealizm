<%@page import="java.util.Locale.Category"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

DeleteContentCParam cParam = new DeleteContentCParam();
cParam.GetParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	DeleteContentC cResults = new DeleteContentC(request.getServletContext());
	bRtn = cResults.GetResults(cParam);
}
%><%=bRtn%>