<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

GetAccountCodeC cResults = new GetAccountCodeC();
cResults.GetParam(request);

if(checkLogin.m_bLogin && checkLogin.m_nUserId==cResults.m_nUserId) {
	cResults.GetResults(checkLogin);
}
%>{"account_code":"<%=cResults.m_strPassWord%>"}