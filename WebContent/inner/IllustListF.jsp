<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
	cResults.m_bDispUnPublished = true;
} else if(cCheckLogin.m_nUserId == cResults.m_nUserId) {
	cResults.m_bDispUnPublished = true;
}

cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin, true);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);%>
	<%if(cCheckLogin.m_nUserId != cResults.m_nUserId){%>
	<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, nSpMode)%>
	<%}else{%>
	<%=CCnv.toMyThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, cCheckLogin, nSpMode)%>
	<%}%>
	<%if(nCnt==17) {%>
	<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
	<%}%>
<%}%>
