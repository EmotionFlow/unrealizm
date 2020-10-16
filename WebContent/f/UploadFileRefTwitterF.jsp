<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.apache.commons.fileupload.*"%>
<%@ page import="org.apache.commons.fileupload.disk.*"%>
<%@ page import="org.apache.commons.fileupload.servlet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
Log.d("UploadReferenceF - UserId:"+cCheckLogin.m_nUserId);

int nRtn = 0;
UploadCParam cParam = new UploadCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);
//Log.d("UploadCParam:"+nRtn);
//Log.d("UploadCParam.m_nUserId:"+cParam.m_nUserId);
//Log.d("UploadCParam.m_nCategoryId:"+cParam.m_nCategoryId);
//Log.d("UploadCParam.m_strDescription:"+cParam.m_strDescription);

if( cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0 ) {
	UploadC cResults = new UploadC();
	nRtn = cResults.GetResults(cParam, cCheckLogin);
	Log.d("UploadC - OK:"+nRtn);
}
%>
{
"content_id":<%=nRtn%>
}
