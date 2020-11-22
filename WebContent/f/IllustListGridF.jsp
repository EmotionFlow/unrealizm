<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = checkLogin.m_nUserId;
}
boolean bRtn = cResults.getResults(checkLogin, true);
ArrayList<String> vResult = Util.getDefaultEmoji(checkLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
	<%if(nCnt==8) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
