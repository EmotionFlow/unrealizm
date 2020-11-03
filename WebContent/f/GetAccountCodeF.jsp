<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

GetAccountCodeC cResults = new GetAccountCodeC();
cResults.GetParam(request);

if(cCheckLogin.m_bLogin && cCheckLogin.m_nUserId==cResults.m_nUserId) {
	cResults.GetResults(cCheckLogin);
}
%>{"account_code":"<%=cResults.m_strPassWord%>"}