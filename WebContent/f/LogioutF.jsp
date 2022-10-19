<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != m_nUserId)) {
	return;
}

Cookie cLK = new Cookie(Common.AI_POIPIKU_LK, "");
cLK.setMaxAge(0);
cLK.setPath("/");
response.addCookie(cLK);
%>{"result":1}