<%@page import="java.util.Locale.Category"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

DeleteCreditCardCParam cParam = new DeleteCreditCardCParam();
cParam.GetParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	DeleteCreditCardC cResults = new DeleteCreditCardC();
	bRtn = cResults.GetResults(cParam);
}else{
	Log.d(String.format("Invalid user %b, %d, %d", cCheckLogin.m_bLogin, cParam.m_nUserId, cCheckLogin.m_nUserId));
}
%><%=bRtn%>