<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) return;

CheckNotifyC cResults = new CheckNotifyC();
cResults.m_nUserId = checkLogin.m_nUserId;
cResults.GetResults();
%>{
"check_comment":<%=cResults.m_nCheckComment%>,
"check_follow":0,
"check_heart":0,
"check_request":<%=cResults.m_nCheckRequest%>,
"notify_comment":<%=cResults.m_nNotifyComment%>,
"notify_follow":0,
"notify_heart":0,
"notify_request":<%=cResults.m_nNotifyRequest%>
}