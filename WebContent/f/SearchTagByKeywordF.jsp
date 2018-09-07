<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchTagByKeywordC cResults = new SearchTagByKeywordC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CTag cTag = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
	<%if((nCnt+1)%9==0) {%>
	<%@ include file="/inner/TAdMid.jspf"%>
	<%}%>
<%}%>
