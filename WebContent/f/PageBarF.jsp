<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	CheckLogin cCheckLogin = new CheckLogin(request, response);
		if(!cCheckLogin.m_bLogin) return;
		int nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
		int nContentsNum = Util.toInt(request.getParameter("TOTAL"));
		int nSelectMaxGallery = Util.toInt(request.getParameter("PARPAGE"));
%>
<%=CPageBar.CreatePageBarSp(null, null, nPage, nContentsNum, nSelectMaxGallery)%>
