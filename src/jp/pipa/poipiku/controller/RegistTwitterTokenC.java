package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import oauth.signpost.OAuthConsumer;
import oauth.signpost.OAuthProvider;
import oauth.signpost.http.HttpParameters;

public final class RegistTwitterTokenC extends Controller {
	public enum Result {
		UNDEF, OK, LINKED_OTHER_POIPIKU_ID, ERROR
	}
	public Result result = Result.UNDEF;

	public boolean getResult(CheckLogin checkLogin, HttpServletRequest request, HttpSession session, ResourceBundleControl _TEX){
		String twitterUserId ="";
		String screenName="";

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean bIsExist;

		// table update or insert
		try {
			OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
			OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");
			if (provider==null) {
				Log.d("provider is null");
				result = Result.ERROR;
				return false;
			}

			String oauth_verifier = request.getParameter("oauth_verifier");
			if (oauth_verifier==null) {
				Log.d("oauth_verifier is null");
				result = Result.ERROR;
				return false;
			}
			provider.retrieveAccessToken(consumer, oauth_verifier);

			HttpParameters hp = provider.getResponseParameters();
			twitterUserId = hp.get("user_id").first();
			screenName = hp.get("screen_name").first();

			connection = DatabaseUtil.dataSource.getConnection();

			// 他のポイピクアカウントがこのTwitterアカウントと紐づいてるかを検索
			sql = "SELECT flduserid FROM tbloauth WHERE flduserid<>? AND twitter_user_id=? AND del_flg=false";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setString(2, twitterUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()){
				result = Result.LINKED_OTHER_POIPIKU_ID;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bIsExist = false;

			if (result==Result.LINKED_OTHER_POIPIKU_ID) {
				return false;
			} else {
				// 以前同じuser_id, twitter_use_idの組み合わせで連携していたら、そのレコードを復活させる。
				sql = "UPDATE tbloauth SET del_flg=FALSE WHERE flduserid=? AND fldproviderid=? AND twitter_user_id=? AND del_flg=TRUE RETURNING flduserid";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, Common.TWITTER_PROVIDER_ID);
				statement.setString(3, twitterUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					Log.d("以前同じuser_id, twitter_use_idの組み合わせで連携していた");
					bIsExist = true;
				}
				resultSet.close();resultSet = null;
				statement.close();statement = null;
			}

			if (!bIsExist) {
				// select
				sql = "SELECT 1 FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, Common.TWITTER_PROVIDER_ID);
				resultSet = statement.executeQuery();
				if(resultSet.next()){
					bIsExist = true;
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if (bIsExist){
				Log.d("TwitterToken Update : " + checkLogin.m_nUserId);
				// update
				sql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, fldDefaultEnable=true, twitter_user_id=?, twitter_screen_name=? WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
				statement = connection.prepareStatement(sql);
				statement.setString(1, consumer.getToken());
				statement.setString(2, consumer.getTokenSecret());
				statement.setString(3, twitterUserId);
				statement.setString(4, screenName);
				statement.setInt(5, checkLogin.m_nUserId);
				statement.setInt(6, Common.TWITTER_PROVIDER_ID);
				statement.executeUpdate();
				statement.close();statement=null;
			} else {
				Log.d("TwitterToken Insert : " + checkLogin.m_nUserId);
				// insert
				sql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?) ";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setInt(2, Common.TWITTER_PROVIDER_ID);
				statement.setString(3, consumer.getToken());
				statement.setString(4, consumer.getTokenSecret());
				statement.setString(5, twitterUserId);
				statement.setString(6, screenName);
				statement.setString(7, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("Common.Title")+String.format(" https://poipiku.com/%d/", checkLogin.m_nUserId));
				statement.executeUpdate();
				statement.close();statement=null;
			}
			result = Result.OK;

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			result = Result.ERROR;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return result == Result.OK;
	}
}
