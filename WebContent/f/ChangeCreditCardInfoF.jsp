<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean result;
CheckLogin checkLogin = new CheckLogin(request, response);
if (!request.getHeader("REFERER").contains("unrealizm.com") || !checkLogin.m_bLogin) {
	Log.d("不正アクセス");
	result = false;
} else {
	ChangeCreditCardInfoC c = new ChangeCreditCardInfoC();
	c.getParam(request);
	result = c.getResults(checkLogin);
}
%>{"result" : <%=(result)?Common.API_OK:Common.API_NG%>}
