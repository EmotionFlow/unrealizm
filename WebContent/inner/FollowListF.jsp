<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;

FollowListC cResults = new FollowListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CUser cUser = cResults.m_vContentList.get(nCnt);%>
	<%if(isApp){%>
		<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
	<%}else{%>
		<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX)%>
	<%}%>
	<%if((nCnt+1)%9==0) {%>
	<%@ include file="/inner/TAdMid.jsp"%>
	<%}%>
<%}%>