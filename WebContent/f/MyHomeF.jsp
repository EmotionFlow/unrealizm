<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
if(!cCheckLogin.m_bLogin) return;

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);
cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin, true);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult)%>
	<%if((nCnt+1)%5==0) {%>
	<%@ include file="/inner/TAdMid.jspf"%>
	<%}%>
<%}%>
