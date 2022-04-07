<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (Util.isBot(request)) return;
IllustViewListC cResults = new IllustViewListC();

cResults.getParam(request);
if (!checkLogin.m_bLogin || checkLogin.m_nUserId!=cResults.m_nUserId) return;

if(cResults.m_nMode==CCnv.MODE_SP) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}

boolean bRtn = cResults.getResults(checkLogin);
if(!bRtn) {
	return;
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%= CCnv.MyContent2Html(cContent, checkLogin, cResults.m_nMode, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>
	<%if(!cResults.m_bAdFilter && (nCnt+1)%10==0) {%>
	<%@ include file="/inner/TAd468x60_mid.jsp"%>
	<%}%>
<%}%>
