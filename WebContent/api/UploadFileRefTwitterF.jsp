<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadCParam cParam = new UploadCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);
//Log.d("UploadCParam:"+nRtn);
//Log.d("UploadCParam.m_nUserId:"+cParam.m_nUserId);
//Log.d("UploadCParam.m_nCategoryId:"+cParam.m_nCategoryId);
//Log.d("UploadCParam.m_strDescription:"+cParam.m_strDescription);
cParam.m_bCheerNg=true;

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadC cResults = new UploadC();
	nRtn = cResults.GetResults(cParam, checkLogin);
}
%>
{
"content_id":<%=nRtn%>
}
