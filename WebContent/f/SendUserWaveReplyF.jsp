<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
SendUserWaveReplyC results = new SendUserWaveReplyC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin, _TEX);
%>{"result" : <%=(bRtn)?Common.API_OK:Common.API_NG%>, "message" : "<%=results.resultMessage%>"}