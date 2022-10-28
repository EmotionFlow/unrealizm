<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UpdateC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UpdateCParam" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateCParam cParam = new UpdateCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UpdateC cResults = new UpdateC();
	nRtn = cResults.GetResults(cParam, checkLogin);
}
%>
{
"content_id":<%=nRtn%>
}
