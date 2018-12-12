package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;

import jp.pipa.poipiku.CComment;
import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.Common;

public class CContent {
	public static final int BOOKMARK_NONE = 0;
	public static final int BOOKMARK_BOOKMARKING = 1;

	public int m_nContentId = 0;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public int m_nUserId = 0;
	public int m_nOpenId = 0;
	public String m_strFileName = "";
	public int m_nFileNum = 0;
	public int m_nBookmarkNum = 0;
	public int m_nCommentNum = 0;
	public int m_nSafeFilter = 0;
	public int m_nFileWidth = 0;
	public int m_nFileHeight = 0;
	public String m_strTagList = "";
	public CUser m_cUser = new CUser();
	public ArrayList<CComment> m_vComment = new ArrayList<CComment>();
	public ArrayList<CContentAppend> m_vContentAppend = new ArrayList<CContentAppend>();

	public int m_nBookmarkState = BOOKMARK_NONE; // アクセスユーザがこのコンテンツをブックマークしてるかのフラグ

	public CContent() {}
	public CContent(ResultSet resultSet) throws SQLException {
		m_nContentId		= resultSet.getInt("content_id");
		m_nCategoryId		= resultSet.getInt("category_id");
		m_strDescription	= Common.ToString(resultSet.getString("description"));
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		m_nUserId			= resultSet.getInt("user_id");
		//m_nOpenId			= resultSet.getInt("open_id");
		m_strFileName		= Common.ToString(resultSet.getString("file_name"));
		m_nFileNum			= resultSet.getInt("file_num");
		m_nBookmarkNum		= resultSet.getInt("bookmark_num");
		//m_nCommentNum		= resultSet.getInt("comment_num");
		m_nSafeFilter		= resultSet.getInt("safe_filter");
		m_nFileWidth		= resultSet.getInt("file_width");
		m_nFileHeight		= resultSet.getInt("file_height");
		m_strTagList		= Common.ToString(resultSet.getString("tag_list"));
		m_cUser.m_nUserId	= resultSet.getInt("user_id");
	}
}
