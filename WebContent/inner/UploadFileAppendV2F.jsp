<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileAppendC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileAppendCParam" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileAppendCParam cParam = new UploadFileAppendCParam(getServletContext());
cParam.userId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.userId ==checkLogin.m_nUserId && nRtn==0 ) {
	UploadFileAppendC cResults = new UploadFileAppendC(getServletContext());
	nRtn = cResults.GetResults(cParam, _TEX, true, isApp);
}

// success, resetはfine uploader側で必要なパラメータ
%>
{"append_id":<%=nRtn%>,"success":true,"reset":false}