<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

IllustViewListC cResults = new IllustViewListC();
cResults.getParam(request);
if(cResults.m_nMode==CCnv.MODE_SP) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
boolean bRtn = cResults.getResults(checkLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(checkLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%= CCnv.Content2Html(cContent, checkLogin.m_nUserId, cResults.m_nMode, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
	<%if(!cResults.m_bAdFilter && (nCnt+1)%10==0) {%>
	<%@ include file="/inner/TAd468x60_mid.jsp"%>
	<%}%>
<%}%>
