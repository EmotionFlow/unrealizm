<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

ReactionListC results = new ReactionListC();
results.getParam(request);

results.getResults(checkLogin);
String html = CCnv.toReactionDetailListHtml(results.reactionDetails, checkLogin, _TEX, true);
%>
{"end_id":<%=results.endId%>,"html":"<%=CEnc.E(html)%>"}
