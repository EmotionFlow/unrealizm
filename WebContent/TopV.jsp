<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
{
	CheckLogin checkLogin = new CheckLogin(request, response);
	if(checkLogin.m_bLogin) {
		response.sendRedirect("/MyHomePcV.jsp");
		return;
	}

// 	boolean bSmartPhone = Util.isSmartPhone(request);
// 	if(!bSmartPhone) {
// 		getServletContext().getRequestDispatcher("/MyHomeGridPcV.jsp").forward(request,response);
// 	} else {
// 		getServletContext().getRequestDispatcher("/MyHomePcV.jsp").forward(request,response);
// 	}
}
%>
<%@include file="/StartPoipikuPcV.jsp"%>
