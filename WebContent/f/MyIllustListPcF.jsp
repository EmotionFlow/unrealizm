<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}

cResults.m_bDispUnPublished = true;

if(!cResults.getResults(cCheckLogin, true)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toMyThumbHtmlPc(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
	<%}%>
<%}%>
