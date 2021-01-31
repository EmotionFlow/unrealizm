<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

PopularIllustListC cResults = new PopularIllustListC();
cResults.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(checkLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%if(isApp){%>
		<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
	<%
		}else{
	%>
		<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
	<%}%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
