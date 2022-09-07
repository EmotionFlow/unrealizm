<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

String referer = Util.toString(request.getHeader("Referer"));
if (referer.indexOf("poipiku.com") != 0) {
	Log.d("Illegal referer.");
	return;
}
if (Util.isBot(request)) {
	Log.d("Access by bot.");
	return;
}

boolean result;

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

AddSwitchUserC controller = new AddSwitchUserC();
controller.getParam(request);
result = controller.getResults(checkLogin, response);

%>{"result":<%=result?Common.API_OK:Common.API_NG%>,"user_id":<%=controller.switchUserId%> ,"error_code":<%=controller.errorKind.getCode()%>,"error_detail_code":<%=controller.errorDetail.getCode()%>}
