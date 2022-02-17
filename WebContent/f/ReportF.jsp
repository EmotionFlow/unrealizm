<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

//パラメータの取得
request.setCharacterEncoding("UTF-8");
int nUserId		= Util.toInt(request.getParameter("ID"));
int nContentId	= Util.toInt(request.getParameter("TD"));
String strReportDesc = Common.TrimAll(Common.EscapeInjection(Util.toString(request.getParameter("DES"))));

try {
	String TO_ADDR		= "info@emotionflow.com";
	String EMAIL_TITLE	= "POIPIKU_REPORT";
	String EMAIL_TXT	= "Post UserId : https://poipiku.com/IllustListPcV.jsp?ID=%d \nTarg Content : https://poipiku.com/IllustViewV.jsp?ID=%d&TD=%d \nReportDesc:%s \n\n";
	EmailUtil.sendByUTF8(TO_ADDR, EMAIL_TITLE, String.format(EMAIL_TXT, checkLogin.m_nUserId, nUserId, nContentId, strReportDesc));
}catch(Exception e) {
	e.printStackTrace();
}
%>{"result":1}