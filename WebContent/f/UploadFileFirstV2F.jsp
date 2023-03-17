<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileFirstC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileFirstCParam" %>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam(getServletContext());
cParam.userId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if(checkLogin.m_bLogin && cParam.userId ==checkLogin.m_nUserId && nRtn==0){
	UploadFileFirstC results = new UploadFileFirstC(getServletContext());
	nRtn = results.GetResults(cParam);
}

// success, resetはfine uploader側で必要なパラメータ
%>
{"content_id":<%=nRtn%>,"success":true,"reset":false}