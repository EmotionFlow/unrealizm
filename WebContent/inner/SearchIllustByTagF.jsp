<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SearchIllustByTagC cResults = new SearchIllustByTagC();
cResults.getParam(request);
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin, true);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%if(isApp){%>
		<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
	<%}else{%>
		<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX)%>
	<%}%>
	<%if(nCnt==14) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}%>
<%}%>
