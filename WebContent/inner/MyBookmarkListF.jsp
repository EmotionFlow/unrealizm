<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyBookmarkC cResults = new MyBookmarkC();
cResults.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(checkLogin, true);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
