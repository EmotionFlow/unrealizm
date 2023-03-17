<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

GetAccountCodeC results = new GetAccountCodeC();
results.GetParam(request);

if(checkLogin.m_bLogin && checkLogin.m_nUserId==results.m_nUserId) {
	results.GetResults(checkLogin);
}
%>{"account_code":"<%=results.m_strPassWord%>"}