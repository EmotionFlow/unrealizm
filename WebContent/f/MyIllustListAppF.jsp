<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}else if(cResults.m_nUserId==cCheckLogin.m_nUserId){
	cResults.m_bDispUnPublished = true;
}

cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

boolean bRtn = cResults.getResults(cCheckLogin, true);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin, CCnv.SP_MODE_APP)%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
	<%}%>
<%}%>
