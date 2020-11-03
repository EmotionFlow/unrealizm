<%@page import="javax.imageio.ImageIO"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.io.*"%>
<%@page import="org.apache.commons.codec.binary.Base64"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateProfileHeaderFileC cResults = new UpdateProfileHeaderFileC();
nRtn = cResults.GetParam(request);

if(cCheckLogin.m_bLogin && cResults.m_nUserId==cCheckLogin.m_nUserId && nRtn==0) {
	nRtn = cResults.GetResults(cCheckLogin, getServletContext());
}
%>{
"result" : <%=nRtn%>
}