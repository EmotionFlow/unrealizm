<%@ page import="jp.pipa.poipiku.controller.upcontents.v1.UploadFileFirstC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v1.UploadFileFirstCParam" %>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam(getServletContext());
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if(checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0){
	UploadFileFirstC cResults = new UploadFileFirstC(getServletContext());
	nRtn = cResults.GetResults(cParam);
}

// success, resetはfine uploader側で必要なパラメータ
%>
{"content_id":<%=nRtn%>,"success":true,"reset":false}