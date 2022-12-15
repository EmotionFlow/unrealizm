<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
int result;
//ReCAPTCHA.VerifyResult verifyResult = ReCAPTCHA.verify(request.getParameter("RTK"));
//if (!verifyResult.success || verifyResult.score < 0.5) {
//	Log.d("reCAPTCHA failure: " + verifyResult.toString());
//	result = -1;
//} else {
	result = UserAuthUtil.checkLogin(request, response);
//}
%>
{"result":<%=result%>}