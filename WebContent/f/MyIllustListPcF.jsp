<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

IllustListGridC cResults = new IllustListGridC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = checkLogin.m_nUserId;
}

cResults.m_bDispUnPublished = true;

if(!cResults.getResults(checkLogin, true)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
