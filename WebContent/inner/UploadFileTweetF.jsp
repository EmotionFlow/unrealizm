<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadFileTweetCParam cParam = new UploadFileTweetCParam();
cParam.m_nUserId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	UploadFileTweetC cResults = new UploadFileTweetC(getServletContext());
	nRtn = cResults.GetResults(checkLogin, cParam, _TEX);
} else 	if(!checkLogin.m_bLogin || cParam.m_nUserId!=checkLogin.m_nUserId){
	nRtn = -1;
}

nRtn = nRtn>0 ? 0 : nRtn;

%>
{"result":<%=nRtn%>}
