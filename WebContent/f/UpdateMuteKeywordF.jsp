<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateMuteKeywordC results = new UpdateMuteKeywordC();
results.getParam(request);

boolean bRtn = false;
if( checkLogin.m_bLogin && results.m_nUserId == checkLogin.m_nUserId ) {
	bRtn = results.getResults(checkLogin);
}
%>{"result": <%=(bRtn)?1:0%>}