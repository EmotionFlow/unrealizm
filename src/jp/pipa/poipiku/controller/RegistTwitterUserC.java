package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Oauth;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;
import oauth.signpost.OAuthConsumer;
import oauth.signpost.OAuthProvider;
import oauth.signpost.exception.OAuthCommunicationException;
import oauth.signpost.exception.OAuthExpectationFailedException;
import oauth.signpost.exception.OAuthMessageSignerException;
import oauth.signpost.exception.OAuthNotAuthorizedException;
import oauth.signpost.http.HttpParameters;
import org.apache.commons.lang3.RandomStringUtils;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class RegistTwitterUserC {
	public static class Result {
		public int poipikuUserId;
		public String hashPassword;
		public Oauth oauth;
	}

	public List<Result> results;
	public int errorCode;

	public static final int ERROR_NONE = 0;
	public static final int ERROR_UNKOWN = -99;
	public static final int ERROR_DB = -98;
	public static final int ERROR_TWITTER = -97;

	public static final int ERROR_TWITTER_CONSUMER_ERROR = -12;
	public static final int ERROR_TWITTER_PROVIDER_ERROR = -13;
	public static final int ERROR_TWITTER_ACCESS_TOKEN_ERROR = -14;
	public static final int ERROR_TWITTER_TOKEN_SECRET_ERROR = -15;
	public static final int ERROR_TWITTER_PROVIDER_PARAMETER_ERROR = -16;
	public static final int ERROR_TWITTER_USER_ID_ERROR = -17;
	public static final int ERROR_TWITTER_SCREEN_NAME_ERROR = -18;

	private final HttpServletRequest request;
	private final HttpServletResponse response;
	private final HttpSession session;

	ResourceBundleControl _TEX;

	public RegistTwitterUserC(HttpServletRequest _request,
	                          HttpServletResponse _response,
	                          HttpSession _session,
	                          ResourceBundleControl __TEX) {
		request = _request;
		response = _response;
		session = _session;
		_TEX = __TEX;
	}

	public static int login(final int userId, final String hashPassword, final Oauth oauth, HttpServletResponse response) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		String nowHashPass = hashPassword;

		// table update or insert
		try {
			connection = DatabaseUtil.dataSource.getConnection();

			String strPassword = "";
			String strEmail = "";
			strSql = "SELECT * FROM users_0000 WHERE user_id=? AND hash_password=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setString(2, hashPassword);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				strPassword = Util.toString(resultSet.getString("password"));
				strEmail = Util.toString((resultSet.getString("email")));
			} else {
				Log.d(strSql);
				return ERROR_UNKOWN;
			}
			resultSet.close();resultSet = null;
			statement.close();statement = null;

			// twitter_user_idのみでの認証を可能とする場合は、ログイン都度トークンとscreen_nameを更新
			strSql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, twitter_screen_name=? WHERE fldUserId=? AND fldproviderid=?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, oauth.accessToken);
			statement.setString(2, oauth.tokenSecret);
			statement.setString(3, oauth.twitterScreenName);
			statement.setInt(4, userId);
			statement.setInt(5, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			statement.close();statement = null;

			// 指定されたポイピクuserId以外のtbloauthレコードにdel_flgを立てる
			strSql = "UPDATE tbloauth SET del_flg=true WHERE twitter_user_id=? AND fldproviderid=?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, oauth.twitterUserId);
			statement.setInt(2, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			statement.close();statement = null;

			strSql = "UPDATE tbloauth SET del_flg=false WHERE flduserid=? AND twitter_user_id=? AND fldproviderid=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setString(2, oauth.twitterUserId);
			statement.setInt(3, Common.TWITTER_PROVIDER_ID);
			statement.executeUpdate();
			statement.close();statement = null;

			if (hashPassword.isEmpty()) {
				final String newHashPassword = Util.getHashPass(strPassword);
				// LKをDB登録
				strSql = "UPDATE users_0000 SET hash_password=? WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setString(1, newHashPassword);
				statement.setInt(2, userId);
				statement.executeUpdate();
				statement.close(); statement = null;
				nowHashPass = newHashPassword;
			}

			// メアド未設定かつ確認中のメアドもなく、twitterから登録メアドを取得でき、
			// 取得したメアドがusers_0000上で他に使われていなかったら、DBに反映させる。
			if (!strEmail.contains("@")) {
				strSql = "SELECT user_id FROM temp_emails_0000 WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, userId);
				resultSet = statement.executeQuery();
				boolean isEmailChecking = resultSet.next();
				resultSet.close(); resultSet = null;
				statement.close(); statement = null;

				if (!isEmailChecking) {
					CTweet tweet = new CTweet();
					String strTwEmail = tweet.GetEmailAddress();
					if (tweet.GetResults(userId) && strTwEmail != null && !strTwEmail.isEmpty()) {
						strSql = "SELECT user_id FROM users_0000 WHERE email = ?";
						statement = connection.prepareStatement(strSql);
						statement.setString(1, strTwEmail);
						resultSet = statement.executeQuery();
						boolean isEmailRegistered = resultSet.next();
						resultSet.close();resultSet = null;
						statement.close();statement = null;

						// twitterから取得したメアドが、他に登録されていなかったら、このポイピクアカウントの
						// メアドとして登録する。
						if (!isEmailRegistered) {
							strSql = "UPDATE users_0000 SET email=? WHERE user_id=?";
							statement = connection.prepareStatement(strSql);
							statement.setString(1, strTwEmail);
							statement.setInt(2, userId);
							statement.executeUpdate();
							statement.close();statement = null;
						}
					}
				}
			} else {
				Log.d("USERAUTH Login error : no user : " + userId);
			}

			setCookie(response, nowHashPass);
			return userId;
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_DB;
		} catch (Exception e) {
			e.printStackTrace();
			return ERROR_UNKOWN;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	public static int register(final HttpServletRequest request, final Oauth oauth, final ResourceBundleControl _TEX, HttpServletResponse response) {
		int userId;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		try {
			String strPassword = RandomStringUtils.randomAlphanumeric(16);
			String strHashPass = Util.getHashPass(strPassword);
			String strEmail = RandomStringUtils.randomAlphanumeric(16);

			// Lang Id
			int nLangId = 1;
			String strLang = Util.toString(request.getParameter(Common.LANG_ID));
			if (strLang.isEmpty()) {
				strLang = Util.toString(Util.getCookie(request, Common.LANG_ID));
			}
			nLangId = (strLang.equals("en")) ? 0 : 1;

			// User名被りチェック
			String strUserName = oauth.twitterScreenName;
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
			connection = DatabaseUtil.dataSource.getConnection();
			strSql = "INSERT INTO users_0000(nickname, password, hash_password, email, profile, lang_id) VALUES(?, ?, ?, ?, ?, ?)";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, strUserName);
			statement.setString(2, strPassword);
			statement.setString(3, strHashPass);
			statement.setString(4, strEmail);
			statement.setString(5, "@" + oauth.twitterScreenName);
			statement.setInt(6, nLangId);
			statement.executeUpdate();
			statement.close();
			statement = null;

			// User ID 取得
			strSql = "SELECT * FROM users_0000 WHERE email=? AND password=?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, strEmail);
			statement.setString(2, strPassword);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				userId = resultSet.getInt("user_id");
			} else {
				userId = -1;
			}
			resultSet.close();resultSet = null;
			statement.close();statement = null;

			if (userId < 1) {
				return ERROR_DB;
			}

			// tbloauthに登録
			strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?) ";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, Common.TWITTER_PROVIDER_ID);
			statement.setString(3, oauth.accessToken);
			statement.setString(4, oauth.tokenSecret);
			statement.setString(5, oauth.twitterUserId);
			statement.setString(6, oauth.twitterScreenName);
			statement.setString(7, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt") + _TEX.T("Common.Title") + String.format(" https://poipiku.com/%d/", userId));
			statement.executeUpdate();
			statement.close();statement = null;

			CTweet tweet = new CTweet();
			String strTwEmail = null;
			if (tweet.GetResults(userId) && (strTwEmail = tweet.GetEmailAddress()) != null) {
				strSql = "SELECT user_id FROM users_0000 WHERE email = ?";
				statement = connection.prepareStatement(strSql);
				statement.setString(1, strTwEmail);
				resultSet = statement.executeQuery();
				boolean bEmailRegistered = resultSet.next();
				resultSet.close();resultSet = null;
				statement.close();statement = null;
				if (!bEmailRegistered) {
					strSql = "UPDATE users_0000 SET email=? WHERE user_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setString(1, strTwEmail);
					statement.setInt(2, userId);
					statement.executeUpdate();
					statement.close();statement = null;
				}
			}

			setCookie(response, strHashPass);
			return userId;
			//Log.d("USERAUTH Regist : " + nUserId);
		} catch (SQLException e) {
			e.printStackTrace();
			return ERROR_DB;
		} catch (Exception e) {
			e.printStackTrace();
			return ERROR_UNKOWN;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	private static void setCookie(HttpServletResponse response, String strHashPass) {
		Cookie cLK = new Cookie(Common.POIPIKU_LK, strHashPass);
		cLK.setMaxAge(Integer.MAX_VALUE);
		cLK.setPath("/");
		response.addCookie(cLK);
	}

	public boolean getResults() {
		results = new ArrayList<>();

		final String accessToken;
		final String tokenSecret;
		String twitterUserId="";
		final String twitterScreenName;
		try {
			OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
			OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");
			if (consumer == null) {
				errorCode = ERROR_TWITTER_CONSUMER_ERROR;
				return false;
			}
			if (provider == null) {
				errorCode = ERROR_TWITTER_PROVIDER_ERROR;
				return false;
			}

			String oauth_verifier = request.getParameter("oauth_verifier");
			if (oauth_verifier == null || oauth_verifier.isEmpty())
				throw (new Exception("USERAUTH oauth_verifier error"));

			provider.retrieveAccessToken(consumer, oauth_verifier);
			accessToken = consumer.getToken();
			tokenSecret = consumer.getTokenSecret();
			if (accessToken == null || accessToken.isEmpty()) {
				errorCode = ERROR_TWITTER_ACCESS_TOKEN_ERROR;
				return false;
			}
			if (tokenSecret == null || tokenSecret.isEmpty()) {
				errorCode = ERROR_TWITTER_TOKEN_SECRET_ERROR;
				return false;
			}

			HttpParameters responseParameters = provider.getResponseParameters();
			if (responseParameters == null) {
				errorCode = ERROR_TWITTER_PROVIDER_PARAMETER_ERROR;
				return false;
			}
			twitterUserId = responseParameters.get("user_id").first();
			if (twitterUserId == null || twitterUserId.isEmpty()) {
				errorCode = ERROR_TWITTER_USER_ID_ERROR;
				return false;
			}
			twitterScreenName = responseParameters.get("screen_name").first();
			if (twitterScreenName == null || twitterScreenName.isEmpty()) {
				errorCode = ERROR_TWITTER_SCREEN_NAME_ERROR;
				return false;
			}
			errorCode = ERROR_NONE;

		} catch (OAuthMessageSignerException e) {
			Log.d("TWITTTER OAuthMessageSignerException");
			errorCode = ERROR_TWITTER;
		} catch (OAuthNotAuthorizedException e) {
			Log.d("TWITTTER OAuthNotAuthorizedException");
			errorCode = ERROR_TWITTER;
		} catch (OAuthExpectationFailedException e) {
			Log.d("TWITTTER OAuthExpectationFailedException");
			errorCode = ERROR_TWITTER;
		} catch (OAuthCommunicationException e) {
			Log.d("TWITTTER OAuthCommunicationException");
			errorCode = ERROR_TWITTER;
		} catch (Exception e) {
			Log.d("USERAUTH EXCEPTION");
			e.printStackTrace();
			errorCode = ERROR_TWITTER;
		}

		if (errorCode != ERROR_NONE) {
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		// table update or insert
		try {
			connection = DatabaseUtil.dataSource.getConnection();

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
			strSql = "SELECT o.*, hash_password FROM tbloauth o INNER JOIN users_0000 u ON flduserid=user_id WHERE twitter_user_id=? ORDER BY fldUserId";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, twitterUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				Oauth o = new Oauth(resultSet);
				Result r = new Result();
				r.poipikuUserId = resultSet.getInt("flduserid");
				r.hashPassword = resultSet.getString("hash_password");
				r.oauth = o;
				results.add(r);
			}
			errorCode = ERROR_NONE;
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			errorCode = ERROR_DB;
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			errorCode = ERROR_UNKOWN;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}
}
