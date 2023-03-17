<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

RandomPickupC results = new RandomPickupC();
results.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = results.getResults(checkLogin, true);
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);%>
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
