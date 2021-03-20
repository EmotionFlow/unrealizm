<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean result = false;
int errorCode = 0;
Request r = new Request(Util.toInt(request.getParameter("ID")));
if (r.creatorUserId == checkLogin.m_nUserId || r.clientUserId == checkLogin.m_nUserId) {
	if (r.cancel() == 0) {
		RequestNotifier.notifyRequestCanceled(checkLogin, r);
		result = true;
	} else {
		errorCode = -3;
	}
} else {
	errorCode = -2;
}

%>{
"result" : <%=result?1:0%>,
"error_code" : <%=errorCode%>
}
