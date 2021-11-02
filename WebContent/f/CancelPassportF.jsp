<%@ page import="java.time.LocalDate" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

boolean bRtn;
int errorCode;

if (LocalDate.now().getDayOfMonth()>=25) {
	Log.d("期間外に解約しようとした");
	bRtn = false;
	errorCode = PassportSubscription.ErrorKind.Unknown.getCode();
} else {
	CancelPassportCParam cParam = new CancelPassportCParam();
	cParam.GetParam(request);

	CancelPassportC cResults = new CancelPassportC();
	bRtn = cResults.getResults(checkLogin, cParam);
	errorCode = cResults.m_nErrCode;
}
%>{"result" : <%=(bRtn)?1:0%>, "error_code" : <%=errorCode%>}
