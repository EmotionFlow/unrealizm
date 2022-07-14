<%@ page import="jp.pipa.poipiku.controller.upcontents.v1.UploadFileAppendC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v1.UploadFileAppendCParam" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean isApp = false;

int nRtn = 0;
UploadFileAppendCParam cParam = new UploadFileAppendCParam(getServletContext());
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadFileAppendC cResults = new UploadFileAppendC(getServletContext());
	nRtn = cResults.GetResults(cParam, _TEX, true, isApp);
}
%>
{
"append_id":<%=nRtn%>
}