<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateNotifyC results = new UpdateNotifyC();
results.GetParam(request);
results.m_nUserId = checkLogin.m_nUserId;

boolean bRtn = results.GetResults(checkLogin);
%>{"result":0}