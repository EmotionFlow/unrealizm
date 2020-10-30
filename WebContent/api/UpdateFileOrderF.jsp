<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateFileOrderC cResults = new UpdateFileOrderC(getServletContext());
cResults.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cResults.GetParam(request);

if (cCheckLogin.m_bLogin && cResults.m_nUserId==cCheckLogin.m_nUserId && nRtn==0) {
	nRtn = cResults.GetResults(cCheckLogin);
}
%>
{"result": <%=nRtn%>}