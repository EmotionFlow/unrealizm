<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

FollowListC cResults = new FollowListC();
cResults.getParam(request);
cResults.m_nMode = followMode;

boolean bRtn = cResults.getResults(checkLogin);
%>
<%for(int nCnt = 0; nCnt<cResults.userList.size(); nCnt++) {
	CUser cUser = cResults.userList.get(nCnt);%>
	<%if(isApp){%>
		<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
	<%}else{%>
		<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW)%>
	<%}%>
<%--	<%if( Util.isSmartPhone(request) && (nCnt+1) % 8 == 0) {%>--%>
<%--	<%@ include file="/inner/TAd336x280_mid.jsp"%>--%>
<%--	<%}%>--%>
<%}%>
