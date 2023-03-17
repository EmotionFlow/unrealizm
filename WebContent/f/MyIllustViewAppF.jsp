<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (Util.isBot(request)) return;
IllustViewListC results = new IllustViewListC();

results.getParam(request);
if (!checkLogin.m_bLogin || checkLogin.m_nUserId!=results.m_nUserId) return;

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

boolean bRtn = results.getResults(checkLogin);
if(!bRtn) return;

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);%>
	<%= CCnv.MyContent2Html(cContent, checkLogin, results.m_nMode, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
	<%if(!results.m_bAdFilter && (nCnt+1)%10==0) {%>
	<%@ include file="/inner/TAd468x60_mid.jsp"%>
	<%}%>
<%}%>
