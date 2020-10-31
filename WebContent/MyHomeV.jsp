<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
getServletContext().getRequestDispatcher("/MyHomeAppV.jsp").forward(request,response);
return;
%>