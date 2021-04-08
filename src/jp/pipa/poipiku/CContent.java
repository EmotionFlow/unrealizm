package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import jp.pipa.poipiku.util.Util;

public final class CContent {
	public static final int BOOKMARK_NONE = 0;
	public static final int BOOKMARK_BOOKMARKING = 1;
	public static final int BOOKMARK_LIMIT = 2;

	public int m_nContentId = 0;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public boolean m_bLimitedTimePublish = false;
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public Timestamp m_timeEndDate = new Timestamp(0);
	public int m_nUserId = 0;
	public int m_nOpenId = 0;
	public boolean m_bNotRecently = false;
	public int m_nEditorId = Common.EDITOR_UPLOAD;
	public String m_strFileName = "";
	public int m_nFileNum = 0;
	public int m_nBookmarkNum = 0;
	public int m_nCommentNum = 0;
	public int m_nSafeFilter = 0;
	public int m_nFileWidth = 0;
	public int m_nFileHeight = 0;
	public String m_strTagList = "";
	public int m_nPublishId = 0;
	public String m_strPassword = "";
	public CUser m_cUser = new CUser();
	public String m_strListId = "";
	public String m_strTweetId = "";
	public int m_nTweetWhenPublished = 0;
	public ArrayList<CComment> m_vComment = new ArrayList<>();
	public String m_strCommentsListsCache = "";
	public ArrayList<CContentAppend> m_vContentAppend = new ArrayList<>();
	public boolean m_bCheerNg = true;
	public String m_strTextBody = "";
	public int m_nGenreId = 1;
	public int m_nRequestId = -1;

	public int m_nBookmarkState = BOOKMARK_NONE; // アクセスユーザがこのコンテンツをブックマークしてるかのフラグ

	public CContent() {}
	public CContent(ResultSet resultSet) throws SQLException {
		m_nContentId		= resultSet.getInt("content_id");
		m_nCategoryId		= resultSet.getInt("category_id");
		m_strDescription	= Util.toString(resultSet.getString("description"));
		m_bLimitedTimePublish=resultSet.getBoolean("limited_time_publish");
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		m_timeEndDate		= resultSet.getTimestamp("end_date");
		m_nUserId			= resultSet.getInt("user_id");
		m_nOpenId			= resultSet.getInt("open_id");
		m_bNotRecently		= resultSet.getBoolean("not_recently");
		m_strFileName		= Util.toString(resultSet.getString("file_name"));
		m_nFileNum			= resultSet.getInt("file_num");
		m_nBookmarkNum		= resultSet.getInt("bookmark_num");
		//m_nCommentNum		= resultSet.getInt("comment_num");
		m_nSafeFilter		= resultSet.getInt("safe_filter");
		m_nFileWidth		= resultSet.getInt("file_width");
		m_nFileHeight		= resultSet.getInt("file_height");
		m_strTagList		= Util.toString(resultSet.getString("tag_list"));
		m_nPublishId		= resultSet.getInt("publish_id");
		m_strListId			= Util.toString(resultSet.getString("list_id"));
		m_cUser.m_nUserId	= resultSet.getInt("user_id");
		m_nEditorId			= resultSet.getInt("editor_id");
		m_strPassword		= Util.toString(resultSet.getString("password"));
		m_strTweetId		= Util.toString(resultSet.getString("tweet_id"));
		m_nTweetWhenPublished=resultSet.getInt("tweet_when_published");
		m_bCheerNg			= resultSet.getBoolean("cheer_ng");
		m_strTextBody		= resultSet.getString("text_body");
		m_nGenreId			= resultSet.getInt("genre_id");

		if(m_nPublishId==0 && m_nSafeFilter>0) {
			switch(m_nSafeFilter) {
			case Common.SAFE_FILTER_R15:
				m_nPublishId = Common.PUBLISH_ID_R15;
				break;
			case Common.SAFE_FILTER_R18:
				m_nPublishId = Common.PUBLISH_ID_R18;
				break;
			case Common.SAFE_FILTER_R18G:
			default:
				m_nPublishId = Common.PUBLISH_ID_R18G;
				break;
			}
		}
	}
}
