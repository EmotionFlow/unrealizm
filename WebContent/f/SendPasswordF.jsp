<%@page import="javax.mail.Transport"%>
<%@page import="javax.mail.Message"%>
<%@page import="javax.mail.internet.InternetAddress"%>
<%@page import="javax.mail.internet.MimeMessage"%>
<%@page import="javax.mail.Session"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendPasswordC {
	public int m_nUserId = -1;
	public String m_strEmail = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_strEmail = Common.EscapeInjection(Common.ToString(request.getParameter("EM"))).toLowerCase();
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		String EMAIL_TITLE	= _TEX.T("SendPasswordV.Email.Title");
		String EMAIL_TXT	= _TEX.T("SendPasswordV.Email.MessageFormat");
		String SMTP_HOST	= "localhost";
		String SMTP_ADDR	= "127.0.0.1";
		String FROM_NAME	= "POIPIKU";
		String FROM_ADDR	= "info@pipa.jp";

		String strMessage = _TEX.T("SendPasswordV.Message.Err");

		CUser user = null;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try{
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM users_0000 WHERE email ILIKE ?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, m_strEmail);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				user = new CUser();
				user.m_nUserId = cResSet.getInt("user_id");
				user.m_strPassword = Common.ToString(cResSet.getString("password"));
			}
			cResSet.close();
			cState.close();


			if (null != user){
				Properties objSmtp = System.getProperties();
				objSmtp.put("mail.smtp.host", SMTP_HOST);
				objSmtp.put("mail.host", SMTP_HOST);
				objSmtp.put("mail.smtp.localhost", SMTP_HOST);
				Session objSession = Session.getDefaultInstance(objSmtp, null);
				MimeMessage objMime = new MimeMessage(objSession);
				objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
				objMime.setRecipients(Message.RecipientType.TO, m_strEmail);
				objMime.setSubject(EMAIL_TITLE, "iso-2022-jp");
				objMime.setText(String.format(EMAIL_TXT, user.m_strPassword), "iso-2022-jp");
				objMime.setHeader("Content-Type", "text/plain; charset=iso-2022-jp");
				objMime.setHeader("Content-Transfer-Encoding", "7bit");
				objMime.setSentDate(new java.util.Date());
				Transport.send(objMime);
				return user.m_nUserId;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cResSet != null) cResSet.close();}catch(Exception e){;}
			try {if(cState != null) cState.close();}catch(Exception e){;}
			try {if(cConn != null) cConn.close();}catch(Exception e){;}
		}
		return -1;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SendPasswordC cResults = new SendPasswordC();
cResults.getParam(request);
int nUserId = cResults.getResults(cCheckLogin, _TEX);
%>{
"result" : <%=nUserId%>
}