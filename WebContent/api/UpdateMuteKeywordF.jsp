<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateMuteKeywordC cResults = new UpdateMuteKeywordC();
cResults.getParam(request);

boolean bRtn = false;
if( checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId ) {
	bRtn = cResults.getResults(checkLogin);
}
%>{"result": <%=(bRtn)?1:0%>}