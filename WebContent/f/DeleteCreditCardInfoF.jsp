<%@page import="java.util.Locale.Category"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

DeleteCreditCardCParam cParam = new DeleteCreditCardCParam();
cParam.GetParam(request);

boolean bRtn = false;
if( checkLogin.m_bLogin && cParam.m_nUserId == checkLogin.m_nUserId ) {
	DeleteCreditCardC results = new DeleteCreditCardC();
	bRtn = results.GetResults(cParam);
}else{
	Log.d(String.format("Invalid user %b, %d, %d", checkLogin.m_bLogin, cParam.m_nUserId, checkLogin.m_nUserId));
}
%><%=bRtn%>