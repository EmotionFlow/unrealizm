<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateFollowTagC cResults = new UpdateFollowTagC();
cResults.getParam(request);

int nRtn = UpdateFollowTagC.ERR_NOT_LOGIN;
if (checkLogin.m_bLogin && cResults.m_nUserId == checkLogin.m_nUserId) {
	nRtn = cResults.getResults(checkLogin);
}
String strMessage = "";
if (nRtn < 0) {
	switch (nRtn) {
		case UpdateFollowTagC.ERR_NOT_LOGIN:
			strMessage = _TEX.T("UpdateFollowTagC.ERR_NOT_LOGIN");
			break;
		case UpdateFollowTagC.ERR_MAX:
			strMessage = String.format(_TEX.T("UpdateFollowTagC.ERR_MAX"), UpdateFollowTagC.FAVO_MAX);
			break;
		case UpdateFollowTagC.ERR_UNKNOWN:
		default:
			strMessage = _TEX.T("UpdateFollowTagC.ERR_UNKNOWN");
			break;
	}
}
%>{"result":<%=nRtn%>, "message" : "<%=CEnc.E(strMessage.toString())%>"}
