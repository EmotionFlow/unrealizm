<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = checkLogin.m_nUserId;
}else if(cResults.m_nUserId==checkLogin.m_nUserId){
	cResults.m_bDispUnPublished = true;
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

boolean bRtn = cResults.getResults(checkLogin, true);
%>
<%if(cResults.m_vContentList.size()>0) {%>
	<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
		CContent cContent = cResults.m_vContentList.get(nCnt);%>
		<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_APP, _TEX)%>
	<%}%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
<%}%>
