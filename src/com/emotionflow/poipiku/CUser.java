package com.emotionflow.poipiku;

import java.util.ArrayList;

import com.emotionflow.poipiku.CContent;

public class CUser {
	public static final int FOLLOW_NONE = 0;
	public static final int FOLLOW_FOLLOWING = 1;
	public static final int FOLLOW_HIDE = -1;

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
	public int m_nAutoTweetTime=-99;
	public String m_strAutoTweetDesc="";
	public int m_nAutoTweetWeekDay = -1;

	public int m_nFollowing = FOLLOW_NONE; // アクセスユーザがこのユーザをフォローしてるかのフラグ
}
