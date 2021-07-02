<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

boolean result = false;
String referer = Util.toString(request.getHeader("Referer"));
if (referer.indexOf("https://poipiku.com/MyIllustList") != 0) {
	Log.d("Illegal referer.");
	return;
}
if (Util.isBot(request)) {
	Log.d("Access by bot.");
	return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

SwitchUserC controller = new SwitchUserC();
controller.getParam(request);
result = controller.getResults(checkLogin, response);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"error_code":<%=controller.errorKind.getCode()%>}
