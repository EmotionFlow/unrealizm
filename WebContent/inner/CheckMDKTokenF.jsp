<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;

CheckMDKTokenC cResults = new CheckMDKTokenC();

int nRtn = cResults.getResults(cCheckLogin);
%>
<%=nRtn%>
