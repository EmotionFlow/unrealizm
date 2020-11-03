<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateNgReactionC cResults = new UpdateNgReactionC();
cResults.getParam(request);

int nMode = CUser.REACTION_SHOW;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	nMode = cResults.getResults(cCheckLogin);
}
%>{"result": <%=nMode%>}