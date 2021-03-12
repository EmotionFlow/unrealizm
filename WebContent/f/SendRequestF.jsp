<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

int result = -1;

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

// Log.d(String.format("ID: %d, ATTR: %s, VAR: %s", clientUserId, request.getParameter("ATTR"), request.getParameter("VAL")));

SendRequestC controller = new SendRequestC();
controller.getParam(request);
if (controller.clientUserId > 0 && controller.creatorUserId > 0) {
	result = controller.getResults(checkLogin);
}

%>{"result":<%=result%>}
