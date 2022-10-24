<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
boolean isPrecheckOK = true;
if (request.getHeader("REFERER")==null || !request.getHeader("REFERER").contains("unrealizm.com")) {
	Log.d(String.format("不正なREFERER: %s, %s, %s, %s",
			request.getRemoteAddr(),
			request.getHeader("REFERER"),
			session.getAttribute("SendPasswordFToken"),
			request.getParameter("TK")));
	isPrecheckOK = false;
} else if (session.getAttribute("SendPasswordFToken")==null || !session.getAttribute("SendPasswordFToken").equals(request.getParameter("TK"))) {
	Log.d(String.format("不正なToken: %s, %s, %s, %s",
			request.getRemoteAddr(),
			request.getHeader("REFERER"),
			session.getAttribute("SendPasswordFToken"),
			request.getParameter("TK")));
	isPrecheckOK = false;
}
session.removeAttribute("SendPasswordFToken");

int nUserId = -1;
if (isPrecheckOK) {
	CheckLogin checkLogin = new CheckLogin(request, response);
	SendPasswordC cResults = new SendPasswordC();
	cResults.getParam(request);
	nUserId = cResults.getResults(checkLogin, _TEX);
}

%>{"result" : <%=nUserId%>}