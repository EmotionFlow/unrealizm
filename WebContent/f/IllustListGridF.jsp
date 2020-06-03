<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
if(cResults.m_nMode==CCnv.MODE_SP || cCheckLogin.m_nUserId==315) {
	cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
boolean bRtn = cResults.getResults(cCheckLogin, true);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, cResults.m_nMode, _TEX, vResult)%>
	<%if(nCnt==8) {%>
	<%@ include file="/inner/TAdPc336x280_bottom_right.jsp"%>
	<%}%>
<%}%>
