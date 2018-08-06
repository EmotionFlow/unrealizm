<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%><%@ page import="javax.naming.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.security.MessageDigest"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));

if(!cCheckLogin.m_bLogin || (cCheckLogin.m_nUserId != m_nUserId)) {
	return;
}

Cookie cLK = new Cookie("ANALOGICO_LK", "");
cLK.setMaxAge(0);
cLK.setPath("/");
response.addCookie(cLK);
%>{"result":1}