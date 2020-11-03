<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateMuteKeywordC cResults = new UpdateMuteKeywordC();
cResults.getParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	bRtn = cResults.getResults(cCheckLogin);
}
%>{"result": <%=(bRtn)?1:0%>}