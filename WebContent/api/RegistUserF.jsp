<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean isPrecheckOK = true;
if (request.getHeader("REFERER")==null || !request.getHeader("REFERER").contains("poipiku.com")) {
	Log.d(String.format("不正なREFERER: %s, %s, %s, %s",
			request.getRemoteAddr(),
			request.getHeader("REFERER"),
			session.getAttribute("RegistUserFToken"),
			request.getParameter("TK")));
	isPrecheckOK = false;
} else if (session.getAttribute("RegistUserFToken")==null || !session.getAttribute("RegistUserFToken").equals(request.getParameter("TK"))) {
	Log.d(String.format("不正なToken: %s, %s, %s, %s",
			request.getRemoteAddr(),
			request.getHeader("REFERER"),
			session.getAttribute("RegistUserFToken"),
			request.getParameter("TK")));
	isPrecheckOK = false;
}

// https://github.com/google/recaptcha/issues/248
//ReCAPTCHA.VerifyResult verifyResult = ReCAPTCHA.verify(request.getParameter("RTK"));
//if (!verifyResult.success || verifyResult.score < 0.5) {
//	Log.d("reCAPTCHA failure: " + verifyResult.toString());
//	isPrecheckOK = false;
//}

int result = -1;
session.removeAttribute("RegistUserFToken");
if (isPrecheckOK) {
	result = UserAuthUtil.registUser(request, response, _TEX);
} else {
	session.removeAttribute("LoginUri");
}

%>
{"result":<%=result%>}
