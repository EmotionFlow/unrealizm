<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.lang.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.nio.channels.FileChannel"%>
<%@ page import="java.sql.Timestamp"%>
<%@page import="com.emotionflow.poipiku.*"%>
<%@page import="com.emotionflow.poipiku.util.*"%>
<%!
class CUser {
	public int m_nUserId = 0;
	public String m_strNickName = "";
	public String m_strProfile = "";
	public String m_strEmail = "";
	public int m_nMailComment = 65535;
	public int m_nLangId = 1;
	public String m_strFileName = "";
	public Vector<CContent> m_vContent = new Vector<CContent>();
	public String m_strPassword = "";
	public String m_strHeaderFileName = "";
	public String m_strBgFileName = "";
	public int m_nFollowNum = 0;
	public int m_nFollowerNum = 0;
	public int m_nHertNum = 0;
	public boolean m_bTweet = false;
	public int m_nAutoTweetTime=-99;
	public String m_strAutoTweetDesc="";
	public int m_nAutoTweetWeekDay = -1;
}

class CContent {
	public int m_nContentId = 0;
	public int m_nCategoryId = 0;
	public int m_nUserId = 0;
	public String m_strFileName = "";
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public Timestamp m_timeUpdateDate = new Timestamp(0);
	public String m_strDescription = "";
	public int m_nProgress = 0;
	public ArrayList<CTag> m_vTag = new ArrayList<CTag>();
	public int m_nOpenId = 0;
	public int m_nAccessNum = 0;
	public int m_nThumbMode = 0;
	public CUser m_cUser = new CUser();
	public CQuote m_cQuote = new CQuote();
	public int m_nQuoteMakingId = 0;
	public boolean m_bBookmark = false;
	public Vector<CComment> m_vComment = new Vector<CComment>();
	public int m_nBookmarkNum = 0;
	public int m_nQuoteMakingNum = 0;
	public int m_nCommentNum = 0;
}

class CComment {
	public int m_nCommentId = 0;
	public int m_nContentId = 0;
	public String m_strDescription = "";
	public int m_nUserId = 0;
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public String m_strNickName = "";
	public String m_strFileName = "";
	public int m_nToUserId = 0;
	public String m_strToNickName = "";
	public int m_nCommentType = 0;
}

class CTag {
	public int m_nTagId = -1;
	public int m_nContentId = -1;
	public String m_strTagTxt = "";
	public int m_nTagType = -1;
}

class CQuote {
	public int m_nQuoteId = -1;
	public String m_strUrl = "";
	public String m_strFileName = "";
	public String m_strTitle = "";
	public String m_strDescription = "";
	public int m_nWidth = 0;
	public int m_nHeight = 0;
}
%>
<%
ResourceBundleControl _TEX = new ResourceBundleControl(request);
int g_nSafeFilter = 0;
%>