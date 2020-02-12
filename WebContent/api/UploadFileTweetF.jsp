<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileTweetCParam cParam = new UploadFileTweetCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadFileTweetC cResults = new UploadFileTweetC(getServletContext());
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{"result":<%=nRtn%>}
