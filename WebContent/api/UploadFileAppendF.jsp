<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileAppendCParam cParam = new UploadFileAppendCParam(getServletContext());
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadFileAppendC cResults = new UploadFileAppendC(getServletContext());
	nRtn = cResults.GetResults(cParam, _TEX);
}

// success, resetはfine uploader側で必要なパラメータ
%>
{"append_id":<%=nRtn%>,"success":true,"reset":false}