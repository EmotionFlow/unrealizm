<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("/f/UpdateFileRefTwitterF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UpdateTextCParam cParam = new UpdateTextCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UpdateTextC cResults = new UpdateTextC();
	nRtn = cResults.GetResults(cParam, cCheckLogin);
	Log.d("UpdateFileRefTwitterF - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}
