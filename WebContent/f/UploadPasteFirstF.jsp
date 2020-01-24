<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam(getServletContext());
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if(cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0){
	UploadFileFirstC cResults = new UploadFileFirstC(getServletContext());
	nRtn = cResults.GetResults(cParam);
}
%>
{
"content_id":<%=nRtn%>
}