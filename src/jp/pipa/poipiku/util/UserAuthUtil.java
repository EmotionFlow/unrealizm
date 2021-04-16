package jp.pipa.poipiku.util;

import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
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
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

import org.apache.commons.lang3.RandomStringUtils;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import oauth.signpost.OAuthConsumer;
import oauth.signpost.OAuthProvider;
import oauth.signpost.exception.OAuthCommunicationException;
import oauth.signpost.exception.OAuthExpectationFailedException;
import oauth.signpost.exception.OAuthMessageSignerException;
import oauth.signpost.exception.OAuthNotAuthorizedException;
import oauth.signpost.http.HttpParameters;

public final class UserAuthUtil {

	public static final int OK = 1;
	public static final int NG = -1;

	public static final int ERROR_UNKOWN = -99;
	public static final int ERROR_DB = -98;
	public static final int ERROR_TWITTER = -97;

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
	public static final int ERROR_TWITTER_CONSUMER_ERROR = -12;
	public static final int ERROR_TWITTER_PROVIDER_ERROR = -13;
	public static final int ERROR_TWITTER_ACCESS_TOKEN_ERROR = -14;
	public static final int ERROR_TWITTER_TOKEN_SECRET_ERROR = -15;
	public static final int ERROR_TWITTER_PROVIDER_PARAMETER_ERROR = -16;
	public static final int ERROR_TWITTER_USER_ID_ERROR = -17;
	public static final int ERROR_TWITTER_SCREEN_NAME_ERROR = -18;

	public static final int LENGTH_EMAIL_MIN = 4;
	public static final int LENGTH_EMAIL_MAX = 64;
	public static final int LENGTH_PASSWORD_MIN = 4;
	public static final int LENGTH_PASSWORD_MAX = 16;
	public static final int LENGTH_NICKNAME_MIN = 3;
	public static final int LENGTH_NICKNAME_MAX = 16;

	public static int checkLogin(HttpServletRequest request, HttpServletResponse response) {
		int nRtn = ERROR_UNKOWN;
		//login check
		//CheckLogin checkLogin = new CheckLogin(request, response);

		//パラメータの取得
		String strEmail	= "";
		String strPassword	= "";
		try {
			request.setCharacterEncoding("UTF-8");
			strEmail	= Common.EscapeInjection(Util.toString(request.getParameter("EM")).trim());
			strPassword	= Common.EscapeInjection(Util.toString(request.getParameter("PW")).trim());
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
				strHashPass = Util.toString(cResSet.getString("hash_password"));
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
			Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
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
		CheckLogin checkLogin = new CheckLogin(request, response);

		//パラメータの取得
		String strEmail	= "";
		String strPassword	= "";
		String strNickName = "";
		try {
			request.setCharacterEncoding("UTF-8");
			strEmail		= Common.EscapeInjection(Util.toString(request.getParameter("EM")).trim());
			strPassword		= Common.EscapeInjection(Util.toString(request.getParameter("PW")).trim());
			strNickName		= Common.EscapeInjection(Util.toString(request.getParameter("NN")).trim());
		} catch(Exception e) {
			e.printStackTrace();
		}
		//Log.d("1:"+strEmail);
		if(strEmail.isEmpty()) return ERROR_EMAIL_EMPTY;
		//Log.d("2:"+strPassword);
		if(strPassword.isEmpty()) return ERROR_PASSWORD_EMPTY;
		//Log.d("3:"+strNickName);
		if(strNickName.isEmpty()) return ERROR_NICKNAME_EMPTY;
		//Log.d("4:"+strEmail);
		if(strEmail.length()<LENGTH_EMAIL_MIN || strEmail.length()>LENGTH_EMAIL_MAX) return ERROR_EMAIL_LENGTH;
		//Log.d("5:"+strPassword);
		if(strPassword.length()<LENGTH_PASSWORD_MIN || strPassword.length()>LENGTH_PASSWORD_MAX) return ERROR_PASSWORD_LENGTH;
		//Log.d("6:"+strNickName);
		if(strNickName.length()<LENGTH_NICKNAME_MIN || strNickName.length()>LENGTH_NICKNAME_MAX) return ERROR_NICKNAME_LENGTH;
		//Log.d("7:"+strEmail);
		if(!strEmail.matches(".+@.+\\..+")) return ERROR_EMAIL_INVALID;
		//Log.d("8:done");
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
			cState.setInt(4, checkLogin.m_nLangId);
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
			Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
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
			strHashKey = Common.EscapeInjection(Util.toString(request.getParameter("HK")).trim());
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
				strEmail = Util.toString(cResSet.getString("email"));
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
			CacheUsers0000.getInstance().clearUser(strHashKey);
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
		//login check
		CheckLogin checkLogin = new CheckLogin(request, response);
		if(!checkLogin.m_bLogin) return ERROR_NOT_LOGIN;

		int nRtn = ERROR_UNKOWN;

		//パラメータの取得
		int nUserId = 0;
		String strPassword = "";
		String strNewPassword1 = "";
		String strNewPassword2 = "";
		try {
			request.setCharacterEncoding("UTF-8");
			nUserId = Util.toInt(request.getParameter("ID"));
			strPassword	= Util.toString(request.getParameter("PW")).trim();
			strNewPassword1 = Util.toString(request.getParameter("PW1")).trim();
			strNewPassword2 = Util.toString(request.getParameter("PW2")).trim();
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(checkLogin.m_nUserId != nUserId) return ERROR_NOT_LOGIN;
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
			cState.setInt(3, checkLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
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
			Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
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
		CheckLogin checkLogin = new CheckLogin(request, response);
		if(!checkLogin.m_bLogin) return ERROR_NOT_LOGIN;

		//パラメータの取得
		int nUserId = 0;
		String strEmail = "";
		try {
			request.setCharacterEncoding("UTF-8");
			nUserId = Util.toInt(request.getParameter("ID"));
			strEmail	= Util.toString(request.getParameter("EM")).trim();
		} catch(Exception e) {
			e.printStackTrace();
		}
		if(checkLogin.m_nUserId != nUserId) return ERROR_NOT_LOGIN;
		if(!strEmail.matches("^([a-zA-Z0-9])+([a-zA-Z0-9\\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\\._-]+)+$")) return ERROR_EMAIL_INVALID;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			boolean bFound = false;
			strSql = "SELECT * FROM users_0000 WHERE email=? AND user_id<>?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strEmail);
			cState.setInt(2, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			bFound = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(bFound) return ERROR_USER_EXIST;

			boolean bRegistNew = false;
			String strNowEmail = null;
			String strPassword = null;
			strSql = "SELECT email, password FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();
			cResSet.next();
			strNowEmail = cResSet.getString("email");
			bRegistNew = !strNowEmail.contains("@");
			if(bRegistNew){
				strPassword = cResSet.getString("password");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

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
			String strEmailText = null;

			// メアド更新ではなく新規登録だったら、メール本文に仮パスワードを含める
			if(!bRegistNew){
				strEmailText = String.format(
						_TEX.T("UpdateEmailAddressV.Mail.MessageFormat"),
						checkLogin.m_strNickName,
						strHashKey);
			}else{
				strEmailText = String.format(
						_TEX.T("UpdateEmailAddressV.Mail.MessageFormatNewRegist"),
						checkLogin.m_strNickName,
						strHashKey,
						strPassword);
			}

			Properties objSmtp = System.getProperties();
			objSmtp.put("mail.smtp.host", SMTP_HOST);
			objSmtp.put("mail.host", SMTP_HOST);
			objSmtp.put("mail.smtp.localhost", SMTP_HOST);
			Session objSession = Session.getDefaultInstance(objSmtp, null);
			MimeMessage objMime = new MimeMessage(objSession);
			objMime.setFrom(new InternetAddress(FROM_ADDR, FROM_NAME, "iso-2022-jp"));
			objMime.setRecipients(Message.RecipientType.TO, strEmail);
			objMime.setSubject(EMAIL_TITLE, "iso-2022-jp");
			objMime.setText(strEmailText, "iso-2022-jp");
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

	// WebContent/RegistTwitterUser.jspとともに廃止予定
	public static int registUserFromTwitter(HttpServletRequest request, HttpServletResponse response, HttpSession session, ResourceBundleControl _TEX) {
		int nRtn = ERROR_UNKOWN;
		List<Oauth> oauthResults = new ArrayList<>();
		int nUserId = -1;
		String strHashPass = "";

		String accessToken = "";
		String tokenSecret = "";
		String twitterUserId = "";
		String twitterScreenName = "";

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		// table update or insert
		try {
			OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
			OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");
			if(consumer==null) return ERROR_TWITTER_CONSUMER_ERROR;
			if(provider==null) return ERROR_TWITTER_PROVIDER_ERROR;

			String oauth_verifier = request.getParameter("oauth_verifier");
			if(oauth_verifier==null || oauth_verifier.isEmpty()) throw(new Exception("USERAUTH oauth_verifier error"));

			provider.retrieveAccessToken(consumer, oauth_verifier);
			accessToken = consumer.getToken();
			tokenSecret = consumer.getTokenSecret();
			if(accessToken==null || accessToken.isEmpty()) return ERROR_TWITTER_ACCESS_TOKEN_ERROR;
			if(tokenSecret==null || tokenSecret.isEmpty()) return ERROR_TWITTER_TOKEN_SECRET_ERROR;

			HttpParameters responseParameters = provider.getResponseParameters();
			if(responseParameters==null) return ERROR_TWITTER_PROVIDER_PARAMETER_ERROR;
			twitterUserId = responseParameters.get("user_id").first();
			if(twitterUserId==null || twitterUserId.isEmpty()) return ERROR_TWITTER_USER_ID_ERROR;
			twitterScreenName = responseParameters.get("screen_name").first();
			if(twitterScreenName==null || twitterScreenName.isEmpty()) return ERROR_TWITTER_SCREEN_NAME_ERROR;

			cConn = DatabaseUtil.dataSource.getConnection();

			// check user
			/*
			// 厳密な認証
			strSql = "SELECT fldUserId FROM tbloauth WHERE fldaccesstoken=? AND fldsecrettoken=? ORDER BY fldUserId DESC LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, accessToken);
			cState.setString(2, tokenSecret);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nUserId = cResSet.getInt("fldUserId");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/

			// 再登録も可能な認証
			//Log.d("USERAUTH twitter userid : ", user_id);
			strSql = "SELECT fldUserId FROM tbloauth WHERE twitter_user_id=? ORDER BY fldUserId";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, twitterUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				Oauth oauthResult = new Oauth(cResSet);
				oauthResults.add(oauthResult);
				nUserId = cResSet.getInt("fldUserId");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if (nUserId>0) {	// Login
				String strPassword = "";
				String strEmail = "";
				strSql = "SELECT * FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					nUserId		= cResSet.getInt("user_id");
					strHashPass = Util.toString(cResSet.getString("hash_password"));
					strPassword = Util.toString(cResSet.getString("password"));
					strEmail = Util.toString((cResSet.getString("email")));
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				if(nUserId>0) {
					// twitter_user_idのみでの認証を可能とする場合は、ログイン都度トークンとscreen_nameを更新
					strSql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, twitter_screen_name=? WHERE fldUserId=? AND del_flg=false";
					cState = cConn.prepareStatement(strSql);
					cState.setString(1, accessToken);
					cState.setString(2, tokenSecret);
					cState.setString(3, twitterScreenName);
					cState.setInt(4, nUserId);
					cState.executeUpdate();
					cState.close();cState=null;

					if(strHashPass.isEmpty()) {
						strHashPass = Util.getHashPass(strPassword);
						// LKをDB登録
						strSql = "UPDATE users_0000 SET hash_password=? WHERE user_id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, strHashPass);
						cState.setInt(2, nUserId);
						cState.executeUpdate();
						cState.close();cState=null;
					}

					// メアド未設定かつ確認中のメアドもなく、twitterから登録メアドを取得でき、
					// 取得したメアドがusers_0000上で他に使われていなかったら、DBに反映させる。
					if(!strEmail.contains("@")){
						strSql = "SELECT user_id FROM temp_emails_0000 WHERE user_id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setInt(1, nUserId);
						cResSet = cState.executeQuery();
						boolean bChecking = cResSet.next();
						cResSet.close();cResSet=null;
						cState.close();cState=null;

						if(!bChecking){
							CTweet tweet = new CTweet();
							String strTwEmail = tweet.GetEmailAddress();
							if(tweet.GetResults(nUserId) && strTwEmail != null && !strTwEmail.isEmpty()){
								strSql = "SELECT user_id FROM users_0000 WHERE email = ?";
								cState = cConn.prepareStatement(strSql);
								cState.setString(1, strTwEmail);
								cResSet = cState.executeQuery();
								boolean bEmailRegistered = cResSet.next();
								cResSet.close();cResSet=null;
								cState.close();cState=null;

								// twitterから取得したメアドが、他に登録されていなかったら、このポイピクアカウントの
								// メアドとして登録する。
								if(!bEmailRegistered){
									strSql = "UPDATE users_0000 SET email=? WHERE user_id=?";
									cState = cConn.prepareStatement(strSql);
									cState.setString(1, strTwEmail);
									cState.setInt(2, nUserId);
									cState.executeUpdate();
									cState.close();cState=null;
								}
							}
						}
					}
				} else {
					Log.d("USERAUTH Login error : no user : " + nUserId);
				}

				Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
				cLK.setMaxAge(Integer.MAX_VALUE);
				cLK.setPath("/");
				response.addCookie(cLK);

				nRtn = nUserId;
			} else { // Register
				//Log.d("USERAUTH Register start");
				String strPassword = RandomStringUtils.randomAlphanumeric(16);
				strHashPass = Util.getHashPass(strPassword);
				String strEmail = RandomStringUtils.randomAlphanumeric(16);

				// Lang Id
				int nLangId=1;
				String strLang = Util.toString(request.getParameter(Common.LANG_ID));
				if(strLang.isEmpty()) {
					strLang = Util.toString(Util.getCookie(request, Common.LANG_ID));
				}
				nLangId = (strLang.equals("en"))?0:1;

				// User名被りチェック
				String strUserName = twitterScreenName;
				/*
				boolean bUserName = false;
				strSql = "SELECT * FROM users_0000 WHERE nickname=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, strUserName);
				cResSet = cState.executeQuery();
				bUserName = cResSet.next();
				cResSet.close();cResSet=null;
				for(int nCnt=0; bUserName; nCnt++) {
					strUserName = String.format("%s_%d", screen_name, nCnt);
					cState.setString(1, strUserName);
					cResSet = cState.executeQuery();
					bUserName = cResSet.next();
					cResSet.close();cResSet=null;
				}
				cState.close();cState=null;
				*/

				// User作成
				strSql = "INSERT INTO users_0000(nickname, password, hash_password, email, profile, lang_id) VALUES(?, ?, ?, ?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, strUserName);
				cState.setString(2, strPassword);
				cState.setString(3, strHashPass);
				cState.setString(4, strEmail);
				cState.setString(5, "@"+twitterScreenName);
				cState.setInt(6, nLangId);
				cState.executeUpdate();
				cState.close();cState=null;

				// User ID 取得
				strSql = "SELECT * FROM users_0000 WHERE email=? AND password=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, strEmail);
				cState.setString(2, strPassword);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					nUserId = cResSet.getInt("user_id");
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				if(nUserId>0) {
					// tbloauthに登録
					strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?) ";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, nUserId);
					cState.setInt(2, Common.TWITTER_PROVIDER_ID);
					cState.setString(3, accessToken);
					cState.setString(4, tokenSecret);
					cState.setString(5, twitterUserId);
					cState.setString(6, twitterScreenName);
					cState.setString(7, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("Common.Title")+String.format(" https://poipiku.com/%d/", nUserId));
					cState.executeUpdate();
					cState.close();cState=null;


					CTweet tweet = new CTweet();
					String strTwEmail = null;
					if(tweet.GetResults(nUserId) && (strTwEmail = tweet.GetEmailAddress()) != null){
						strSql = "SELECT user_id FROM users_0000 WHERE email = ?";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, strTwEmail);
						cResSet = cState.executeQuery();
						boolean bEmailRegistered = cResSet.next();
						cResSet.close();cResSet=null;
						cState.close();cState=null;

						if(!bEmailRegistered) {
							strSql = "UPDATE users_0000 SET email=? WHERE user_id=?";
							cState = cConn.prepareStatement(strSql);
							cState.setString(1, strTwEmail);
							cState.setInt(2, nUserId);
							cState.executeUpdate();
							cState.close();cState=null;
						}
					}

					Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
					cLK.setMaxAge(Integer.MAX_VALUE);
					cLK.setPath("/");
					response.addCookie(cLK);

					nRtn = nUserId;
					//Log.d("USERAUTH Regist : " + nUserId);
				}
			}
		} catch(OAuthMessageSignerException e) {
			Log.d("TWITTTER OAuthMessageSignerException");
			nRtn = ERROR_TWITTER;
		} catch(OAuthNotAuthorizedException e) {
			Log.d("TWITTTER OAuthNotAuthorizedException");
			nRtn = ERROR_TWITTER;
		} catch(OAuthExpectationFailedException e) {
			Log.d("TWITTTER OAuthExpectationFailedException");
			nRtn = ERROR_TWITTER;
		} catch(OAuthCommunicationException e) {
			Log.d("TWITTTER OAuthCommunicationException");
			nRtn = ERROR_TWITTER;
		} catch(Exception e) {
			Log.d(strSql);
			Log.d("USERAUTH EXCEPTION");
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
