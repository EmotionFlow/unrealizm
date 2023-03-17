<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(checkLogin.m_bLogin) {
	response.sendRedirect("/MyHomePcV.jsp");
} else {
	getServletContext().getRequestDispatcher("/NewArrivalV.jsp").forward(request,response);
}
%>
