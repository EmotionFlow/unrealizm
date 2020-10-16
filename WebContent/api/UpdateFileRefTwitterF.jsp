<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("/api/UpdateFileRefTwitterF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UpdateCParam cParam = new UpdateCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateC cResults = new UpdateC();
	nRtn = cResults.GetResults(cParam, cCheckLogin);
	Log.d("UpdateFileRefTwitterF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}
