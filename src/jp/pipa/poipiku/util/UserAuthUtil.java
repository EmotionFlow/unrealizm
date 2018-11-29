package jp.pipa.poipiku.util;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.naming.InitialContext;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;

public class UserAuthUtil {

	public static final int OK = 1;
	public static final int NG = -1;

	public static final int ERROR_UNKOWN = -99;
	public static final int ERROR_DB = -98;

	public static final int ERROR_EMAIL_EMPTY = -1;
	public static final int ERROR_PASSWORD_EMPTY = -2;
	public static final int ERROR_NICKNAME_EMPTY = -3;
	public static final int ERROR_EMAIL_LENGTH = -4;
	public static final int ERROR_PASSWORD_LENGTH = -5;
	public static final int ERROR_NICKNAME_LENGTH = -6;
	public static final int ERROR_EMAIL_INVALID = -7;
	public static final int ERROR_USER_EXIST = -8;
	public static final int ERROR_HUSH_INVALID = -9;
	public static final int ERROR_NOT_LOGIN = -10;
	public static final int ERROR_PASSWORD_ERROR = -11;


	public static final int LENGTH_EMAIL_MIN = 4;
	public static final int LENGTH_EMAIL_MAX = 64;
	public static final int LENGTH_PASSWORD_MIN = 4;
	public static final int LENGTH_PASSWORD_MAX = 16;
	public static final int LENGTH_NICKNAME_MIN = 4;
	public static final int LENGTH_NICKNAME_MAX = 16;

	public static int checkLogin(HttpServletRequest request, HttpServletResponse response) {
		int nRtn = ERROR_UNKOWN;
		//login check
		CheckLogin cCheckLogin = new CheckLogin();
		cCheckLogin.GetResults2(request, response);

		//パラメータの取得
		String strEmail	= "";
		String strPassword	= "";
		try {
			request.setCharacterEncoding("UTF-8");
			strEmail	= Common.EscapeInjection(Common.ToString(request.getParameter("EM")).trim());
			strPassword	= Common.EscapeInjection(Common.ToString(request.getParameter("PW")).trim());
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(strEmail.isEmpty()) return ERROR_EMAIL_EMPTY;
		if(strPassword.isEmpty()) return ERROR_PASSWORD_EMPTY;
		if(strEmail.length()<LENGTH_EMAIL_MIN || strEmail.length()>LENGTH_EMAIL_MAX) return ERROR_EMAIL_LENGTH;
		if(strPassword.length()<LENGTH_PASSWORD_MIN || strPassword.length()>LENGTH_PASSWORD_MAX) return ERROR_PASSWORD_LENGTH;

		int nUserId = 0;
		String strHashPass = "";
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM users_0000 WHERE email=? AND password=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strEmail);
			cState.setString(2, strPassword);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nUserId = cResSet.getInt("user_id");
				strHashPass = Common.ToString(cResSet.getString("hash_password"));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nRtn = ERROR_DB;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		if(!strHashPass.isEmpty()) {
			Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
			nRtn = nUserId;
		}
		return nRtn;
	}


	public static int registUser(HttpServletRequest request, HttpServletResponse response, ResourceBundleControl _TEX) {
		int nRtn = ERROR_UNKOWN;
		//login check
		CheckLogin cCheckLogin = new CheckLogin();
		cCheckLogin.GetResults2(request, response);

		//パラメータの取得
		String strEmail	= "";
		String strPassword	= "";
		String strNickName = "";
		try {
			request.setCharacterEncoding("UTF-8");
			strEmail		= Common.EscapeInjection(Common.ToString(request.getParameter("EM")).trim());
			strPassword		= Common.EscapeInjection(Common.ToString(request.getParameter("PW")).trim());
			strNickName		= Common.EscapeInjection(Common.ToString(request.getParameter("NN")).trim());
		} catch(Exception e) {
			e.printStackTrace();
		}
		Log.d("1:"+strEmail);
		if(strEmail.isEmpty()) return ERROR_EMAIL_EMPTY;
		Log.d("2:"+strPassword);
		if(strPassword.isEmpty()) return ERROR_PASSWORD_EMPTY;
		Log.d("3:"+strNickName);
		if(strNickName.isEmpty()) return ERROR_NICKNAME_EMPTY;
		Log.d("4:"+strEmail);
		if(strEmail.length()<LENGTH_EMAIL_MIN || strEmail.length()>LENGTH_EMAIL_MAX) return ERROR_EMAIL_LENGTH;
		Log.d("5:"+strPassword);
		if(strPassword.length()<LENGTH_PASSWORD_MIN || strPassword.length()>LENGTH_PASSWORD_MAX) return ERROR_PASSWORD_LENGTH;
		Log.d("6:"+strNickName);
		if(strNickName.length()<LENGTH_NICKNAME_MIN || strNickName.length()>LENGTH_NICKNAME_MAX) return ERROR_NICKNAME_LENGTH;
		Log.d("7:"+strEmail);
		if(!strEmail.matches(".+@.+\\..+")) return ERROR_EMAIL_INVALID;
		Log.d("8:done");
		int nUserId = 0;
		String strHashPass = "";
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM users_0000 WHERE email=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strEmail);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nUserId = cResSet.getInt("user_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nUserId>0) return ERROR_USER_EXIST;

			// hash password
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((strPassword + Math.random()).getBytes());
			byte[] hash= md5.digest();
			StringBuffer sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if(d < 16) {
					m = String.format("%1$02x", d);
				}
				sb.append(m);
			}
			strHashPass = sb.toString();

			// regist user
			strSql = "INSERT INTO users_0000(nickname, password, hash_password, lang_id, email) VALUES(?, ?, ?, ?, ?) RETURNING user_id";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strNickName);
			cState.setString(2, strPassword);
			cState.setString(3, strHashPass);
			cState.setInt(4, cCheckLogin.m_nLangId);
			cState.setString(5, strEmail);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nUserId = cResSet.getInt("user_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nUserId<=0) return ERROR_UNKOWN;

			// temp email
			String strHashKey = "";
			md5.reset();
			md5.update((strEmail + Math.random()).getBytes());
			hash= md5.digest();
			sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String hex = Integer.toString(d, 16);
				if(d < 16) {
					hex = String.format("%1$02x", d);
				}
				sb.append(hex);
			}
			strHashKey = sb.toString();

			strSql = "DELETE FROM temp_emails_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			strSql = "INSERT INTO temp_emails_0000(user_id, email, hash_key) VALUES(?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setString(2, strEmail);
			cState.setString(3, strHashKey);
			cState.executeUpdate();
			cState.close();cState=null;


			// email
			final String SMTP_HOST = "localhost";
			final String FROM_NAME = "POIPIKU";
			final String FROM_ADDR = "info@poipiku.com";
			final String EMAIL_TITLE = _TEX.T("RegistMailV.EmailVaid.Title");
			final String EMAIL_TXT = String.format(_TEX.T("RegistMailV.EmailVaid.MessageFormat"), strNickName, strHashKey);
			Properties objSmtp = System.getProperties();
			objSmtp.put("mail.smtp.host", SMTP_HOST);
			objSmtp.put("mail.host", SMTP_HOST);
			objSmtp.put("mail.smtp.localhost", SMTP_HOST);
			Session objSession = Session.getDefaultInstance(objSmtp, null);
			MimeMessage objMime = new MimeMessage(objSession);
			objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
			objMime.setRecipients(Message.RecipientType.TO, strEmail);
			objMime.setSubject(EMAIL_TITLE, "iso-2022-jp");
			objMime.setText(EMAIL_TXT, "iso-2022-jp");
			objMime.setHeader("Content-Type", "text/plain; charset=iso-2022-jp");
			objMime.setHeader("Content-Transfer-Encoding", "7bit");
			objMime.setSentDate(new java.util.Date());
			Transport.send(objMime);
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nRtn = ERROR_DB;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		if(!strHashPass.isEmpty() && nUserId>0) {
			Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
			nRtn = nUserId;
		} else {
			nRtn = NG;
		}
		return nRtn;
	}


	public static int activateEmail(HttpServletRequest request, HttpServletResponse response) {
		int nRtn = ERROR_UNKOWN;

		//パラメータの取得
		String strHashKey = "";
		try {
			request.setCharacterEncoding("UTF-8");
			strHashKey = Common.EscapeInjection(Common.ToString(request.getParameter("HK")).trim());
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(strHashKey.isEmpty()) return ERROR_HUSH_INVALID;

		int nUserId = 0;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			String strEmail = "";
			strSql = "SELECT * FROM temp_emails_0000 WHERE hash_key=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strHashKey);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				strEmail = Common.ToString(cResSet.getString("email"));
				nUserId = cResSet.getInt("user_id");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nUserId<=0) return ERROR_HUSH_INVALID;

			strSql = "UPDATE users_0000 SET email=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strEmail);
			cState.setInt(2, nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

			strSql = "DELETE FROM temp_emails_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			nRtn = nUserId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nRtn = ERROR_DB;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}

	public static int updatePassword(HttpServletRequest request, HttpServletResponse response) {
		int nRtn = ERROR_UNKOWN;
		//login check
		CheckLogin cCheckLogin = new CheckLogin();
		cCheckLogin.GetResults2(request, response);
		if(!cCheckLogin.m_bLogin) return ERROR_NOT_LOGIN;

		//パラメータの取得
		int nUserId = 0;
		String strPassword = "";
		String strNewPassword1 = "";
		String strNewPassword2 = "";
		try {
			request.setCharacterEncoding("UTF-8");
			nUserId = Common.ToInt(request.getParameter("ID"));
			strPassword	= Common.ToString(request.getParameter("PW")).trim();
			strNewPassword1 = Common.ToString(request.getParameter("PW1")).trim();
			strNewPassword2 = Common.ToString(request.getParameter("PW2")).trim();
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(cCheckLogin.m_nUserId != nUserId) return ERROR_NOT_LOGIN;
		if(strPassword.isEmpty()) return ERROR_PASSWORD_EMPTY;
		if(strNewPassword1.length()<LENGTH_PASSWORD_MIN || strNewPassword1.length()>LENGTH_PASSWORD_MAX) return ERROR_PASSWORD_LENGTH;
		if(strNewPassword2.length()<LENGTH_PASSWORD_MIN || strNewPassword2.length()>LENGTH_PASSWORD_MAX) return ERROR_PASSWORD_LENGTH;
		if(!strNewPassword1.equals(strNewPassword1)) return ERROR_PASSWORD_ERROR;


		String strHashPass = "";
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			boolean bAuth = false;
			strSql = "SELECT * FROM users_0000 WHERE user_id=? AND password=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setString(2, strPassword);
			cResSet = cState.executeQuery();
			bAuth = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bAuth) return ERROR_NOT_LOGIN;

			// hash password
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((strNewPassword1 + Math.random()).getBytes());
			byte[] hash= md5.digest();
			StringBuffer sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if(d < 16) {
					m = String.format("%1$02x", d);
				}
				sb.append(m);
			}
			strHashPass = sb.toString();

			strSql = "UPDATE users_0000 SET password=?, hash_password=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strNewPassword1);
			cState.setString(2, strHashPass);
			cState.setInt(3, cCheckLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nRtn = ERROR_DB;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		if(!strHashPass.isEmpty()) {
			Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
			nRtn = nUserId;
		}
		return nRtn;
	}

	public static int updateEmail(HttpServletRequest request, HttpServletResponse response, ResourceBundleControl _TEX) {
		int nRtn = ERROR_UNKOWN;
		//login check
		CheckLogin cCheckLogin = new CheckLogin();
		cCheckLogin.GetResults2(request, response);
		if(!cCheckLogin.m_bLogin) return ERROR_NOT_LOGIN;

		//パラメータの取得
		int nUserId = 0;
		String strEmail = "";
		try {
			request.setCharacterEncoding("UTF-8");
			nUserId = Common.ToInt(request.getParameter("ID"));
			strEmail	= Common.ToString(request.getParameter("EM")).trim();
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(cCheckLogin.m_nUserId != nUserId) return ERROR_NOT_LOGIN;
		if(!strEmail.matches("^([a-zA-Z0-9])+([a-zA-Z0-9\\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\\._-]+)+$")) return ERROR_EMAIL_INVALID;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			boolean bFind = false;
			strSql = "SELECT * FROM users_0000 WHERE email=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strEmail);
			cResSet = cState.executeQuery();
			bFind = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(bFind) return ERROR_USER_EXIST;

			// hash password
			MessageDigest md5 = MessageDigest.getInstance("SHA-256");
			md5.reset();
			md5.update((strEmail + Math.random()).getBytes());
			byte[] hash= md5.digest();
			StringBuffer sb= new StringBuffer();
			for(int i=0; i<hash.length; i++) {
				int d = hash[i];
				if(d < 0) d += 256;
				String m = Integer.toString(d, 16);
				if(d < 16) {
					m = String.format("%1$02x", d);
				}
				sb.append(m);
			}
			String strHashKey = sb.toString();

			strSql = "DELETE FROM temp_emails_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			strSql = "INSERT INTO temp_emails_0000(user_id, email, hash_key) VALUES(?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setString(2, strEmail);
			cState.setString(3, strHashKey);
			cState.executeUpdate();
			cState.close();cState=null;

			final String SMTP_HOST = "localhost";
			final String FROM_NAME = "POIPIKU";
			final String FROM_ADDR = "info@poipiku.com";
			final String EMAIL_TITLE = _TEX.T("UpdateEmailAddressV.Mail.Title");
			final String EMAIL_TXT = String.format(_TEX.T("UpdateEmailAddressV.Mail.MessageFormat"), cCheckLogin.m_strNickName, strHashKey);
			Properties objSmtp = System.getProperties();
			objSmtp.put("mail.smtp.host", SMTP_HOST);
			objSmtp.put("mail.host", SMTP_HOST);
			objSmtp.put("mail.smtp.localhost", SMTP_HOST);
			Session objSession = Session.getDefaultInstance(objSmtp, null);
			MimeMessage objMime = new MimeMessage(objSession);
			objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
			objMime.setRecipients(Message.RecipientType.TO, strEmail);
			objMime.setSubject(EMAIL_TITLE, "iso-2022-jp");
			objMime.setText(EMAIL_TXT, "iso-2022-jp");
			objMime.setHeader("Content-Type", "text/plain; charset=iso-2022-jp");
			objMime.setHeader("Content-Transfer-Encoding", "7bit");
			objMime.setSentDate(new java.util.Date());
			Transport.send(objMime);
			nRtn = nUserId;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			nRtn = ERROR_DB;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
