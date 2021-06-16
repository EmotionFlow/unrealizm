<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean result = false;
int errorCode = 0;
Request r = new Request(Util.toInt(request.getParameter("ID")));
if (r.creatorUserId == checkLogin.m_nUserId || r.clientUserId == checkLogin.m_nUserId) {
	result = r.cancel();
	if (result) {
		// スケブに倣ってキャンセル通知はしないでおく。
		//RequestNotifier.notifyRequestCanceled(checkLogin, r);
	} else {
		errorCode = r.errorKind.getCode();
	}
} else {
	errorCode = -99;
}

%>{
"result" : <%=result?Common.API_OK:Common.API_NG%>,
"error_code" : <%=errorCode%>
}
