<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

IllustViewListC results = new IllustViewListC();
results.getParam(request);
if(results.m_nMode==CCnv.MODE_SP) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
boolean bRtn = results.getResults(checkLogin);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);%>
	<%= CCnv.Content2Html(content, checkLogin, results.m_nMode, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
<%}%>
