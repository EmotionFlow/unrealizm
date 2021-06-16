package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Util;

public class CUser {
	public static final int FOLLOW_NONE = 0;
	public static final int FOLLOW_FOLLOWING = 1;
	public static final int FOLLOW_HIDE = -1;

	public static final int REACTION_SHOW = 0;
	public static final int REACTION_HIDE = 1;

	public static final int AD_MODE_HIDE = 0;
	public static final int AD_MODE_SHOW = 1;

	public static final int DOWNLOAD_OFF = 0;
	public static final int DOWNLOAD_ON = 1;

	public static final int SEND_EMAIL_OFF = 0;
	public static final int SEND_EMAIL_ON = 1;

	public int m_nUserId = 0;
	public String m_strNickName = "";
	public String m_strProfile = "";
	public String m_strEmail = "";
	public int m_nMailComment = 65535;
	public int m_nLangId = 1;
	public String m_strFileName = "";
	public ArrayList<CContent> m_vContent = new ArrayList<CContent>();
	public String m_strPassword = "";
	public String m_strHeaderFileName = "";
	public String m_strBgFileName = "";
	public String m_strMuteKeyword = "";
	public int m_nFollowNum = 0;
	public int m_nFollowerNum = 0;
	public boolean m_bTweet = false;
	public boolean m_bDispFollower = false;
	public boolean m_bDispR18 = false;
	public int m_nReaction = REACTION_SHOW;
	public int m_nAdMode = AD_MODE_HIDE;
	public int m_nDownload = DOWNLOAD_OFF;
	public int m_nPassportId = Common.PASSPORT_OFF;
	public int m_nSendEmailMode = 1;

	// tblOAuth
	public int m_nAutoTweetTime=-99;
	public String m_strAutoTweetDesc="";
	public int m_nAutoTweetWeekDay = -1;
	public int m_nAutoTweetThumbNum = 9;
	public String m_strTwitterScreenName = "";

	public int m_nFollowing = FOLLOW_NONE; // アクセスユーザがこのユーザをフォローしてるかのフラグ

	public boolean m_bRequestEnabled = false;

	public CUser() {}
	public CUser(final ResultSet resultSet) throws SQLException {
		m_nUserId		= resultSet.getInt("user_id");
		m_strNickName	= Util.toString(resultSet.getString("nickname"));
		m_strFileName	= Util.toString(resultSet.getString("file_name"));
		m_nPassportId	= resultSet.getInt("passport_id");
		if(m_strFileName.isEmpty()) m_strFileName="/img/default_user.jpg";
	}
	
	public CUser(final CacheUsers0000.User cashUser) {
		if (cashUser==null) return;
		m_nUserId = cashUser.userId;
		m_strFileName = cashUser.fileName;
		m_strHeaderFileName = cashUser.headerFileName;
		m_strNickName = cashUser.nickName;
		m_strProfile = cashUser.profile;
	}
	
	public void setRequestEnabled(final ResultSet resultSet) throws SQLException {
		m_bRequestEnabled = (resultSet.getInt("request_creator_status") == RequestCreator.Status.Enabled.getCode());
	}
}
