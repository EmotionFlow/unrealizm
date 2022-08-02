package jp.pipa.poipiku.util;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.TwitterRetweet;
import jp.pipa.poipiku.controller.CheckCreditCardC;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class ContentAccessVerificationUtil {
	public static final int ERR_T_FOLLOWER = -5;
	public static final int ERR_T_FOLLOW = -6;
	public static final int ERR_T_EACH = -7;
	public static final int ERR_T_LIST = -8;
//	public static final int ERR_T_NEED_RETWEET = -20;
	public static final int ERR_T_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_T_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_T_TARGET_ACCOUNT_NOT_FOUND = -98;
	public static final int ERR_T_UNLINKED = -10;
//	public static final int ERR_HIDDEN = -9;
	public static final int ERR_UNKNOWN = -99;

	static public boolean verifyRequestClient(CContent content, CheckLogin checkLogin) {
		boolean result = false;
		final String sql = "SELECT 1 FROM requests WHERE content_id=? AND client_user_id=?";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, content.m_nContentId);
			statement.setInt(2, checkLogin.m_nUserId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				result = true;
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}
		return result;
	}


	static public boolean verifyPassword(CContent content, String enteredPassword) {
		return content.m_strPassword.equals(enteredPassword);
	}

	static public boolean verifyPoipassLogin(CheckLogin checkLogin) {
		return checkLogin.m_bLogin;
	}

	static public boolean verifyR18Plus(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) return false;
		CheckCreditCardC checkCreditCardC = new CheckCreditCardC();
		return checkCreditCardC.getResults(checkLogin) == 1;
	}

	static public boolean verifyPoipassFollower(CContent content, CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) return false;

		boolean result = false;
		final String sql = "SELECT 1 FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, content.m_nUserId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				result = true;
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}
		return result;
	}

	public static class VerifyTwitterResult {
		public int code;
		public String myTwitterScreenName;
		public VerifyTwitterResult() {}
	}

	static public VerifyTwitterResult verifyTwitterFollowing(CContent content, CheckLogin checkLogin, int twFriendship) {
		VerifyTwitterResult result = new VerifyTwitterResult();

		if (!checkLogin.m_bLogin) {
			if (content.m_nPublishId== Common.PUBLISH_ID_T_FOLLOWER) {
				result.code = ERR_T_FOLLOWER;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) {
				result.code = ERR_T_FOLLOW;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
				result.code = ERR_T_EACH;
			} else {
				result.code = ERR_UNKNOWN;
			}
			return result;
		}
		CTweet cTweet = new CTweet();
		if(cTweet.GetResults(checkLogin.m_nUserId)){
			if (!cTweet.m_bIsTweetEnable) {
				result.code = ERR_T_UNLINKED;
				return result;
			}

			result.myTwitterScreenName = cTweet.m_strScreenName;
			if(twFriendship==CTweet.FRIENDSHIP_UNDEF
					|| (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && (twFriendship==CTweet.FRIENDSHIP_NONE || twFriendship==CTweet.FRIENDSHIP_FOLLOWER))
					|| (content.m_nPublishId==Common.PUBLISH_ID_T_EACH     && (twFriendship==CTweet.FRIENDSHIP_NONE || twFriendship==CTweet.FRIENDSHIP_FOLLOWER))
			){
				twFriendship = cTweet.LookupFriendship(content.m_nUserId, content.m_nPublishId);
				if(twFriendship==CTweet.ERR_RATE_LIMIT_EXCEEDED){
					result.code =  ERR_T_RATE_LIMIT_EXCEEDED;
					return result;
				} else if (twFriendship==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN) {
					result.code =  ERR_T_INVALID_OR_EXPIRED_TOKEN;
					return result;
				} else if (twFriendship==CTweet.ERR_TARGET_TW_ACCOUNT_NOT_FOUND) {
					result.code =  ERR_T_TARGET_ACCOUNT_NOT_FOUND;
					return result;
				} else if (twFriendship==CTweet.ERR_OTHER) {
					Log.d("twFriendship==CTweet.ERR_OTHER");
					result.code =  ERR_UNKNOWN;
					return result;
				}
			}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && !(twFriendship==CTweet.FRIENDSHIP_FOLLOWEE || twFriendship==CTweet.FRIENDSHIP_EACH)){
				result.code = ERR_T_FOLLOWER;
				return result;
			}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE && !(twFriendship==CTweet.FRIENDSHIP_FOLLOWER || twFriendship==CTweet.FRIENDSHIP_EACH)){
				result.code = ERR_T_FOLLOW;
				return result;
			}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_EACH && !(twFriendship==CTweet.FRIENDSHIP_EACH)){
				result.code = ERR_T_EACH;
				return result;
			}
		}

		result.code = 0;
		return result;
	}

	static public VerifyTwitterResult verifyTwitterOpenList(CContent content, CheckLogin checkLogin) {
		VerifyTwitterResult result = new VerifyTwitterResult();

		if (!checkLogin.m_bLogin) {
			result.code = ERR_T_LIST;
			return result;
		}
		CTweet cTweet = new CTweet();
		if(cTweet.GetResults(checkLogin.m_nUserId)){
			if(!cTweet.m_bIsTweetEnable){
				result.code = ERR_T_UNLINKED;
				return result;
			}
			result.myTwitterScreenName = cTweet.m_strScreenName;
			int nRet = cTweet.LookupListMember(content);
			if(nRet==CTweet.ERR_NOT_FOUND){
				result.code = ERR_T_LIST;
				return result;
			}
			if(nRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
				result.code = ERR_T_INVALID_OR_EXPIRED_TOKEN;
				return result;
			}
			if(nRet==CTweet.ERR_RATE_LIMIT_EXCEEDED) {
				result.code = ERR_T_RATE_LIMIT_EXCEEDED;
				return result;
			}
			if(nRet<0) {
				Log.d("nRet<0)");
				result.code = ERR_UNKNOWN;
				return result;
			}
		} else {
			Log.d("cTweet.GetResults(checkLogin.m_nUserId) return false");
			result.code = ERR_UNKNOWN;
			return result;
		}

		result.code = 0;
		return result;
	}

	static public boolean verifyTwitterRetweet(CContent content, CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			return false;
		}
		return TwitterRetweet.find(checkLogin.m_nUserId, content.m_nContentId);
	}

}
