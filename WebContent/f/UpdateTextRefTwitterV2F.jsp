<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UpdateTextC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UpdateTextCParam" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateTextCParam cParam = new UpdateTextCParam();
cParam.userId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.userId==checkLogin.m_nUserId && nRtn==0 ) {
	UpdateTextC results = new UpdateTextC();
	nRtn = results.GetResults(cParam, checkLogin);
}
%>
{"content_id":<%=nRtn%>}
