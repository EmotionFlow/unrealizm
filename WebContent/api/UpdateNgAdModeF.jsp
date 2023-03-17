<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateNgAdModeC results = new UpdateNgAdModeC();
results.getParam(request);

int nMode = CUser.AD_MODE_HIDE;
if(checkLogin.m_bLogin && results.m_nUserId == checkLogin.m_nUserId) {
	nMode = results.getResults(checkLogin);
}
%>{"result": <%=nMode%>}