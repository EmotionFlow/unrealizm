package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import jp.pipa.poipiku.CContent;

public class CUser {
	public static final int FOLLOW_NONE = 0;
	public static final int FOLLOW_FOLLOWING = 1;
	public static final int FOLLOW_HIDE = -1;

	public static final int REACTION_SHOW = 0;
	public static final int REACTION_HIDE = 1;

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

	// tblOAuth
	public int m_nAutoTweetTime=-99;
	public String m_strAutoTweetDesc="";
	public int m_nAutoTweetWeekDay = -1;
	public int m_nAutoTweetThumbNum = 9;
	public String m_strTwitterScreenName = "";

	public int m_nFollowing = FOLLOW_NONE; // アクセスユーザがこのユーザをフォローしてるかのフラグ

	public CUser() {}
	public CUser(ResultSet resultSet) throws SQLException {
		m_nUserId		= resultSet.getInt("user_id");
		m_strNickName	= Common.ToString(resultSet.getString("nickname"));
		m_strFileName	= Common.ToString(resultSet.getString("file_name"));
		if(m_strFileName.isEmpty()) m_strFileName="/img/default_user.jpg";
	}
}
