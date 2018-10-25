<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
if(!cCheckLogin.m_bLogin) return;

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CTag cTag = cResults.m_vContentList.get(nCnt);%>
	<%if(cTag.m_nTypeId==Common.FOVO_KEYWORD_TYPE_TAG) {%>
	<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
	<%} else {%>
	<%=CCnv.toHtmlKeyword(cTag, CCnv.MODE_SP, _TEX)%>
	<%}%>
	<%if((nCnt+1)%9==0) {%>
	<%@ include file="/inner/TAdMid.jspf"%>
	<%}%>
<%}%>
