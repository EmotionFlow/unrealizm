<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustViewListC cResults = new IllustViewListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%= CCnv.toHtml(cContent, cCheckLogin.m_nUserId, cResults.m_nMode, _TEX)%>
	<%if((nCnt+1)%3==0) {%>
	<%@ include file="/inner/TAdMid.jspf"%>
	<%}%>
<%}%>
