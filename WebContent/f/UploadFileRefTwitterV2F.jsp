<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadC" %>
<%@ page import="jp.pipa.poipiku.controller.upcontents.v2.UploadCParam" %>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UploadCParam cParam = new UploadCParam();
cParam.userId = checkLogin.m_nUserId;
nRtn = cParam.GetParam(request);
//Log.d("checlLogin.userId:"+checkLogin.m_nUserId);
//Log.d("UploadCParam:"+nRtn);
//Log.d("UploadCParam.m_nUserId:"+cParam.userId);
//Log.d("UploadCParam.m_nCategoryId:"+cParam.categoryId);
//Log.d("UploadCParam.m_strDescription:"+cParam.description);
//cParam.m_bCheerNg=true;	// スマホからcheerできないように -> アプリからこのパラメータを送ってないのでtrueがデフォルト

UploadC results = null;
if( checkLogin.m_bLogin && cParam.userId==checkLogin.m_nUserId && nRtn==0 ) {
	results = new UploadC();
	nRtn = results.GetResults(cParam, checkLogin);
} else {
	return;
}
%>
{"content_id":<%=nRtn%>,"open_id":<%=results.openId%>,"deliver_request_result":<%=results.deliverRequestResult%>}
