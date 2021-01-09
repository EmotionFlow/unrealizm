<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateNgAdModeC cResults = new UpdateNgAdModeC();
cResults.getParam(request);

int nMode = CUser.AD_MODE_HIDE;
if(checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId) {
	nMode = cResults.getResults(checkLogin);
}
%>{"result": <%=nMode%>}