<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateFollowCParam cParam = new UpdateFollowCParam();
cParam.GetParam(request);

String buttonLabel = "";
String errMsg = "";
int nRtn = -1;
if( checkLogin.m_bLogin && cParam.m_nUserId == checkLogin.m_nUserId ) {
	UpdateFollowC cResults = new UpdateFollowC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
if (nRtn == 1) {
	buttonLabel = _TEX.T("IllustV.Following");
} else if (nRtn == 2) {
	buttonLabel = _TEX.T("IllustV.Follow");
} else {
	buttonLabel = _TEX.T("IllustV.Follow");
	errMsg = "フォローできませんでした";
}
%>{"result":<%=nRtn%>, "btn_label":"<%=buttonLabel%>", "err_msg":"<%=errMsg%>"}