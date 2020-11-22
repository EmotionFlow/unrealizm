<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadTextCParam cParam = new UploadTextCParam();
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadTextC cResults = new UploadTextC();
	nRtn = cResults.GetResults(cParam, checkLogin);
}
%>
{
"content_id":<%=nRtn%>
}
