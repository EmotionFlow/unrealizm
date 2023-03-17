<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListGridC results = new IllustListGridC();
results.getParam(request);
if(results.m_nUserId==-1) {
	results.m_nUserId = checkLogin.m_nUserId;
}
boolean bRtn = results.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);%>
	<%=CCnv.Content2Html(cContent, checkLogin, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_LIST, CCnv.SP_MODE_WVIEW)%>
	<%if(nCnt==8) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
