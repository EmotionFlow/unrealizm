package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.CodeEnum;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
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
			sql = "SELECT tweet_id FROM contents_0000 WHERE content_id=? AND open_id<>2 AND publish_id<>99";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				retweetId = resultSet.getLong(1);
				if (retweetId <= 0) {
					errorDetail = ErrorDetail.TweetIdNotFound;
				}
			} else {
				errorDetail = ErrorDetail.RecordNotFound;
			}

			resultSet.close();resultSet=null;
			statement.close();statement=null;
			connection.close();connection=null;

			CTweet cTweet = new CTweet();
			cTweet.GetResults(checkLogin.m_nUserId);
			result = cTweet.ReTweet(contentId, retweetId);
			if (result == CTweet.RETWEET_DONE || result == CTweet.RETWEET_ALREADY) {
				errorDetail = ErrorDetail.None;
			} else {
				errorDetail = ErrorDetail.Unknown;
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
