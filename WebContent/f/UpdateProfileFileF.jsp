<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateProfileFileC results = new UpdateProfileFileC();
nRtn = results.GetParam(request);

if(checkLogin.m_bLogin && results.m_nUserId==checkLogin.m_nUserId && nRtn==0) {
	nRtn = results.GetResults(checkLogin, getServletContext());
}
%>{
"result" : <%=nRtn%>
}