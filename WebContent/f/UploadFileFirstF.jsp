<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

Log.d("UploadFileFirstF.jsp entered");

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam(getServletContext());
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileFirstC cResults = new UploadFileFirstC(getServletContext());
	nRtn = cResults.GetResults(cParam);
}
%>
{
"content_id":<%=nRtn%>
}