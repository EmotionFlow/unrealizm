package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public final class ShowAppendFileC {
	public static final int OK = 0;
	public static final int ERR_NOT_FOUND = -1;
	public static final int ERR_PASS = -2;
	public static final int ERR_LOGIN = -3;
	public static final int ERR_FOLLOWER = -4;
	public static final int ERR_T_FOLLOWER = -5;
	public static final int ERR_T_FOLLOW = -6;
	public static final int ERR_T_EACH = -7;
	public static final int ERR_T_LIST = -8;
	public static final int ERR_T_NEED_RETWEET = -20;
	public static final int ERR_T_RATE_LIMIT_EXCEEDED = -429088;
	public static final int ERR_T_INVALID_OR_EXPIRED_TOKEN = -404089;
	public static final int ERR_T_TARGET_ACCOUNT_NOT_FOUND = -98;
	public static final int ERR_T_UNLINKED = -10;
	public static final int ERR_HIDDEN = -9;
	public static final int ERR_UNKNOWN = -99;

	public int contentUserId = -1;
	public int contentId = -1;
	public String m_strPassword = "";
	public int m_nSpMode = 0;
	public int m_nTwFriendship = CTweet.FRIENDSHIP_UNDEF;
	public String m_strMyTwitterScreenName = "";

	public void getParam(HttpServletRequest request) {
		try {
			contentUserId = Util.toInt(request.getParameter("UID"));
			contentId = Util.toInt(request.getParameter("IID"));
			m_strPassword = request.getParameter("PAS");
			m_nSpMode = Util.toInt(request.getParameter("MD"));
			m_nTwFriendship = Util.toInt(request.getParameter("TWF"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			contentId = -1;
		}
	}


	public CContent content = null;

	private boolean verifyRequestClient(CheckLogin checkLogin) {
		boolean result = false;

		final String sql = "SELECT 1 FROM requests WHERE content_id=? AND client_user_id=?";
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		PreparedStatement statement = connection.prepareStatement(sql)) {
			statement.setInt(1, contentId);
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


	private boolean verifyPassword() {
		return content.m_strPassword.equals(m_strPassword);
	}

	private boolean verifyPoipassLogin(CheckLogin checkLogin) {
		return checkLogin.m_bLogin;
	}

	private boolean verifyPoipassFollower(CheckLogin checkLogin) {
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

	private int verifyTwitterFollowing(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER) {
				return ERR_T_FOLLOWER;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE) {
				return ERR_T_FOLLOW;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
				return ERR_T_EACH;
			}
			return ERR_UNKNOWN;
		}
		CTweet cTweet = new CTweet();
		if(cTweet.GetResults(checkLogin.m_nUserId)){
			if (!cTweet.m_bIsTweetEnable) {
				return ERR_T_UNLINKED;
			}

			m_strMyTwitterScreenName = cTweet.m_strScreenName;
			if(m_nTwFriendship==CTweet.FRIENDSHIP_UNDEF
					|| (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
					|| (content.m_nPublishId==Common.PUBLISH_ID_T_EACH     && (m_nTwFriendship==CTweet.FRIENDSHIP_NONE || m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER))
			){
				m_nTwFriendship = cTweet.LookupFriendship(contentUserId, content.m_nPublishId);
				if(m_nTwFriendship==CTweet.ERR_RATE_LIMIT_EXCEEDED){
					return ERR_T_RATE_LIMIT_EXCEEDED;
				} else if (m_nTwFriendship==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN) {
					return ERR_T_INVALID_OR_EXPIRED_TOKEN;
				} else if (m_nTwFriendship==CTweet.ERR_TARGET_TW_ACCOUNT_NOT_FOUND) {
					return ERR_T_TARGET_ACCOUNT_NOT_FOUND;
				} else if (m_nTwFriendship==CTweet.ERR_OTHER) {
					Log.d("m_nTwFriendship==CTweet.ERR_OTHER");
					return ERR_UNKNOWN;
				}
			}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWEE || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOWER;}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE && !(m_nTwFriendship==CTweet.FRIENDSHIP_FOLLOWER || m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_FOLLOW;}
			if(content.m_nPublishId==Common.PUBLISH_ID_T_EACH && !(m_nTwFriendship==CTweet.FRIENDSHIP_EACH)){return ERR_T_EACH;}
		}

		return 0;
	}

	private int verifyTwitterOpenList(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			return ERR_T_LIST;
		}
		CTweet cTweet = new CTweet();
		if(cTweet.GetResults(checkLogin.m_nUserId)){
			if(!cTweet.m_bIsTweetEnable){
				return ERR_T_UNLINKED;
			}
			m_strMyTwitterScreenName = cTweet.m_strScreenName;
			int nRet = cTweet.LookupListMember(content);
			if(nRet==CTweet.ERR_NOT_FOUND) return ERR_T_LIST;
			if(nRet==CTweet.ERR_INVALID_OR_EXPIRED_TOKEN) return ERR_T_INVALID_OR_EXPIRED_TOKEN;
			if(nRet==CTweet.ERR_RATE_LIMIT_EXCEEDED) return ERR_T_RATE_LIMIT_EXCEEDED;
			if(nRet<0) {
				Log.d("nRet<0)");
				return ERR_UNKNOWN;
			}
		} else {
			Log.d("cTweet.GetResults(checkLogin.m_nUserId) return false");
			return ERR_UNKNOWN;
		}

		return 0;
	}

	private boolean verifyTwitterRetweet(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			return false;
		}
		return TwitterRetweet.find(checkLogin.m_nUserId, content.m_nContentId);
	}

	public int getResults(CheckLogin checkLogin) {
		content = null;
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(
					 "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?"
		     )
		) {
			statement.setInt(1, contentUserId);
			statement.setInt(2, contentId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				content = new CContent(resultSet);
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}
		if(content == null) return ERR_NOT_FOUND;

		boolean isRequestClient = verifyRequestClient(checkLogin);
		boolean isOwner = content.m_nUserId == checkLogin.m_nUserId;

		if (!isRequestClient && content.passwordEnabled) {
			if (!verifyPassword()) return ERR_PASS;
		}

		if (!isOwner && !isRequestClient) {
			if (content.m_nPublishId == Common.PUBLISH_ID_LOGIN && !verifyPoipassLogin(checkLogin)) return ERR_LOGIN;
			if (content.m_nPublishId == Common.PUBLISH_ID_FOLLOWER && !verifyPoipassFollower(checkLogin)) return ERR_FOLLOWER;
			if (!content.nowAvailable()) return ERR_HIDDEN;
			if (content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWER
					|| content.m_nPublishId==Common.PUBLISH_ID_T_FOLLOWEE
					|| content.m_nPublishId==Common.PUBLISH_ID_T_EACH) {
				int resultCode = verifyTwitterFollowing(checkLogin);
				if (resultCode < 0) return resultCode;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_LIST) {
				int resultCode = verifyTwitterOpenList(checkLogin);
				if (resultCode < 0) return resultCode;
			}
			if (content.m_nPublishId==Common.PUBLISH_ID_T_RT && !verifyTwitterRetweet(checkLogin)) return ERR_T_NEED_RETWEET;
		}

		int nRtn;
		try (Connection connection = DatabaseUtil.dataSource.getConnection();
		     PreparedStatement statement = connection.prepareStatement(
				     "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000"
		     )
		) {
			statement.setInt(1, contentId);
			ResultSet resultSet = statement.executeQuery();
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				content.m_vContentAppend.add(new CContentAppend(resultSet));
			}
			nRtn = content.m_vContentAppend.size();
		} catch (SQLException throwables) {
			throwables.printStackTrace();
			nRtn = ERR_UNKNOWN;
		}
		return nRtn;
	}
}
