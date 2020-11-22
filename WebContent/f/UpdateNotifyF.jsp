<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateNotifyC cResults = new UpdateNotifyC();
cResults.GetParam(request);
cResults.m_nUserId = checkLogin.m_nUserId;

boolean bRtn = cResults.GetResults(checkLogin);
%>{"result":0}