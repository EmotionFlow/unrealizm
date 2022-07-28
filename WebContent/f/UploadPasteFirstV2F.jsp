<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileFirstC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadFileFirstCParam" %>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileFirstCParam cParam = new UploadFileFirstCParam(getServletContext());
cParam.userId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if(checkLogin.m_bLogin && cParam.userId ==checkLogin.m_nUserId && nRtn==0){
	UploadFileFirstC cResults = new UploadFileFirstC(getServletContext());
	nRtn = cResults.GetResults(cParam);
}
%>
{"content_id":<%=nRtn%>}