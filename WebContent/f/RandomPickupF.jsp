<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

RandomPickupC results = new RandomPickupC();
results.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = results.getResults(checkLogin, true);
%>
<%for(CContent content: results.contentList) {%>
	<%=CCnv.Content2Html2Column(content, checkLogin, _TEX)%>
<%}%>
