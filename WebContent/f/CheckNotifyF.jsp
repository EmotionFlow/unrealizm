<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

CheckNotifyC cResults = new CheckNotifyC();
cResults.GetParam(request);
cResults.m_nUserId = checkLogin.m_nUserId;
boolean bRtn = cResults.GetResults(checkLogin);
%>{
"check_comment":<%=cResults.m_nCheckComment%>,
"check_follow":<%=cResults.m_nCheckFollow%>,
"check_heart":<%=cResults.m_nCheckHeart%>,
"notify_comment":<%=cResults.m_nNotifyComment%>,
"notify_follow":<%=cResults.m_nNotifyFollow%>,
"notify_heart":<%=cResults.m_nNotifyHeart%>
}