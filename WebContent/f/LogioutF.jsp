<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
	return;
}

Cookie cLK = new Cookie("POIPIKU_LK", "");
cLK.setMaxAge(0);
cLK.setPath("/");
response.addCookie(cLK);
%>{"result":1}