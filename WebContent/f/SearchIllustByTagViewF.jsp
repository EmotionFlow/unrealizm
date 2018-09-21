<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchIllustByTagViewC cResults = new SearchIllustByTagViewC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 5;
boolean bRtn = cResults.getResults(cCheckLogin, true);
ArrayList<String> vResult = Util.getRankEmojiDaily(Common.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult)%>
	<%//if((nCnt+1)%2==0) {%>
	<%//@ include file="/inner/TAdMid.jspf"%>
	<%//}%>
<%}%>
<%@ include file="/inner/TAdMid.jspf"%>
