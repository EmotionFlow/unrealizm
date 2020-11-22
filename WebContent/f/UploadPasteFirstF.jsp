<%@page import="org.apache.commons.codec.binary.Base64"%>
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
%>
{
"content_id":<%=nRtn%>
}