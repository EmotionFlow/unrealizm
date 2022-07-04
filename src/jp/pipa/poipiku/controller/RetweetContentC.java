package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.CodeEnum;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RetweetContentC extends Controller {
	public int contentId = -1;

	public ErrorDetail errorDetail= ErrorDetail.Unknown;
	public enum ErrorDetail implements CodeEnum<RetweetContentC.ErrorDetail> {
		None(0),
		RecordNotFound(-10),	    // 自分を外そうとした
		TweetIdNotFound(-20),	    // 削除対象が見つからなかった
		RetweetError(-30),          // リツイート時にエラー
		NotSignedIn(-40),           // ポイピクにログインしていない
		Unknown(-99);         // 不明。通常ありえない。

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private ErrorDetail(int code) {
			this.code = code;
		}
	}

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			contentId = Util.toInt(request.getParameter("TD"));
		} catch(Exception ignored) { }
	}

	public int getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			errorKind = ErrorKind.Unknown;
			errorDetail = ErrorDetail.NotSignedIn;
			return CTweet.ERR_OTHER;
		}

		int result = CTweet.ERR_OTHER;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		long retweetId = -1;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT tweet_id FROM contents_0000 WHERE content_id=? AND open_id<>2";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				final String strRetweetId = resultSet.getString(1);
				if (strRetweetId == null || strRetweetId.isEmpty()) {
					Log.d("TweetIdNotFound: " + contentId);
					errorDetail = ErrorDetail.TweetIdNotFound;
 				} else {
					try {
						retweetId = Long.parseLong(strRetweetId);
					} catch (NumberFormatException e) {
						Log.d("NumberFormatException: " + contentId + ", " + strRetweetId);
					}
					if (retweetId <= 0) {
						errorDetail = ErrorDetail.TweetIdNotFound;
					}
				}
			} else {
				errorDetail = ErrorDetail.RecordNotFound;
			}

			resultSet.close();resultSet=null;
			statement.close();statement=null;
			connection.close();connection=null;

			if (errorDetail != ErrorDetail.TweetIdNotFound && errorDetail != ErrorDetail.RecordNotFound) {
				CTweet cTweet = new CTweet();
				cTweet.GetResults(checkLogin.m_nUserId);
				result = cTweet.ReTweet(contentId, retweetId);
				if (result == CTweet.RETWEET_DONE || result == CTweet.RETWEET_ALREADY) {
					errorDetail = ErrorDetail.None;
				} else {
					Log.d("cTweet.ReTweet() failed: " + result);
					errorDetail = ErrorDetail.Unknown;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {if(resultSet!=null)resultSet.close();}catch(Exception e){}
			try {if(statement!=null)statement.close();}catch(Exception e){}
			try {if(connection!=null)connection.close();}catch(Exception e){}
		}

		return result;
	}
}
