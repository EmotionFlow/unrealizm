<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//String referer = Util.toString(request.getHeader("Referer"));
//if (!referer.contains("unrealizm")) return;
if (Util.isBot(request)) return;

CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) return;

ReplyEmojiC results = new ReplyEmojiC();
results.getParam(request);
boolean result = results.getResults(checkLogin, _TEX);
%>{"result" : <%=(result)?Common.API_OK:Common.API_NG%>, "error_code" : <%=results.errorCode%>, "message" : "<%=results.message%>"}