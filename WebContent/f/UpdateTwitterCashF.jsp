<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int userId = Util.toInt(request.getParameter("ID"));

if(!checkLogin.m_bLogin || (checkLogin.m_nUserId != userId)) return;

CTweet.updateTwitterCash(userId);
%>{"result":1}