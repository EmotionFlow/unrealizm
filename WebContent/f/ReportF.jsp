<%@page import="com.sun.xml.internal.org.jvnet.mimepull.MIMEMessage"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

//パラメータの取得
request.setCharacterEncoding("UTF-8");
int nContentId	= Common.ToInt(request.getParameter("TD"));
String strReportDesc = Common.TrimAll(Common.EscapeInjection(Common.ToString(request.getParameter("DES"))));

try {
	String SMTP_HOST	= "localhost";
	String FROM_NAME	= "POIPIKU_REPORT";
	String FROM_ADDR	= "poipiku@pipa.jp";
	String TO_ADDR		= "info@emotionflow.com";
	String EMAIL_TITLE	= "POIPIKU_REPORT";
	String EMAIL_TXT	= "Post UserId : https://poipiku.com/IllustListPcV.jsp?ID=%d \nTarg Content : https://poipiku.com/IllustViewV.jsp?TD=%d \nReportDesc:%s \n\n";

	Log.d(String.format(EMAIL_TXT, cCheckLogin.m_nUserId, nContentId, strReportDesc));

	Properties objSmtp = System.getProperties();
	objSmtp.put("mail.smtp.host", SMTP_HOST);
	objSmtp.put("mail.host", SMTP_HOST);
	objSmtp.put("mail.smtp.localhost", SMTP_HOST);
	Session objSession = Session.getDefaultInstance(objSmtp, null);
	MimeMessage objMime = new MimeMessage(objSession);
	objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
	objMime.setRecipients(Message.RecipientType.TO, TO_ADDR);
	objMime.setSubject(EMAIL_TITLE, "iso-2022-jp");
	objMime.setText(String.format(EMAIL_TXT, cCheckLogin.m_nUserId, nContentId, strReportDesc), "iso-2022-jp");
	objMime.setHeader("Content-Type", "text/plain; charset=iso-2022-jp");
	objMime.setHeader("Content-Transfer-Encoding", "7bit");
	objMime.setSentDate(new java.util.Date());
	Transport.send(objMime);

	Log.d(String.format(EMAIL_TXT, cCheckLogin.m_nUserId, nContentId, strReportDesc));
}catch(Exception e) {
	e.printStackTrace();
}
%>{"result":1}