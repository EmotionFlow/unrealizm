<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
    CheckLogin cCheckLogin = new CheckLogin(request, response);
    if(!cCheckLogin.m_bLogin) return;
    int nPage = Math.max(Common.ToInt(request.getParameter("PG")), 0);
    int nContentsNum = Common.ToInt(request.getParameter("TOTAL"));
    int nSelectMaxGallery = Common.ToInt(request.getParameter("PARPAGE"));
%>
<%=CPageBar.CreatePageBar(null, null, nPage, nContentsNum, nSelectMaxGallery)%>
