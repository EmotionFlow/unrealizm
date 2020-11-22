<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

FollowListC cResults = new FollowListC();
cResults.getParam(request);
if(!isApp) {
	cResults.SELECT_MAX_GALLERY = 8;
}

boolean bRtn = cResults.getResults(checkLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CUser cUser = cResults.m_vContentList.get(nCnt);%>
	<%if(isApp){%>
		<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
	<%}else{%>
		<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX)%>
	<%}%>
	<%if((nCnt+1)%9==0) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}%>
<%}%>
