<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

ReactionListC cResults = new ReactionListC();
cResults.getParam(request);

cResults.getResults(checkLogin);
String html = CCnv.toReactionDetailListHtml(cResults.reactionDetails, checkLogin, _TEX);
%>
{"end_id":<%=cResults.endId%>,"html":"<%=CEnc.E(html)%>"}
