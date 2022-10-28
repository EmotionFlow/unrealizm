<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadCParam" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
//cParam.m_bCheerNg=true;	// スマホからcheerできないように -> アプリからこのパラメータを送ってないのでtrueがデフォルト

UploadC cResults = null;
if( checkLogin.m_bLogin && cParam.m_nUserId==checkLogin.m_nUserId && nRtn==0 ) {
	cResults = new UploadC();
	nRtn = cResults.GetResults(cParam, checkLogin);
} else {
	return;
}
%>
{
"content_id":<%=nRtn%>,
"deliver_request_result":<%=cResults.deliverRequestResult%>
}
