<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%><%@ page import="javax.naming.*"%>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

//パラメータの取得
request.setCharacterEncoding("UTF-8");
int nContentId	= Common.ToInt(request.getParameter("TD"));
String strReportDesc = Common.TrimAll(Common.EscapeInjection(Common.ToString(request.getParameter("DES"))));

try {
	String SMTP_HOST	= "localhost";
	String FROM_NAME	= "ANALOGICO_REPORT";
	String FROM_ADDR	= "analogico@pipa.jp";
	String TO_ADDR	= "info@pipa.jp";
	String EMAIL_TITLE = "ANALOGICO_REPORT";
	String EMAIL_TXT = "Post UserId : https://analogico.pipa.jp/IllustListPcV.jsp?ID=%d \nTarg Content : https://analogico.pipa.jp/IllustViewV.jsp?TD=%d \nReportDesc:%s \n\n";

	System.out.println(String.format(EMAIL_TXT, cCheckLogin.m_nUserId, nContentId, strReportDesc));

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
}catch(Exception e) {
	e.printStackTrace();
}
%>{"result":1}