package com.emotionflow.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Vector;

import com.emotionflow.poipiku.CComment;
import com.emotionflow.poipiku.CUser;
import com.emotionflow.poipiku.Common;

public class CContent {
	public int m_nContentId = 0;
	public int m_nCategoryId = 0;
	public String m_strDescription = "";
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public int m_nUserId = 0;
	public int m_nOpenId = 0;
	public String m_strFileName = "";
	public int m_nAccessNum = 0;
	public int m_nBookmarkNum = 0;
	public int m_nCommentNum = 0;
	public CUser m_cUser = new CUser();
	public Vector<CComment> m_vComment = new Vector<CComment>();
	public boolean m_bBookmark = false;

	public CContent() {}
	public CContent(ResultSet resultSet) throws SQLException {
		m_nContentId		= resultSet.getInt("content_id");
		m_nCategoryId		= resultSet.getInt("category_id");
		m_strDescription	= Common.ToString(resultSet.getString("description"));
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		m_nUserId			= resultSet.getInt("user_id");
		//m_nOpenId			= resultSet.getInt("open_id");
		m_strFileName		= Common.ToString(resultSet.getString("file_name"));
		//m_nAccessNum		= resultSet.getInt("access_num");
		m_nBookmarkNum		= resultSet.getInt("bookmark_num");
		m_nCommentNum		= resultSet.getInt("comment_num");
		m_cUser.m_nUserId	= resultSet.getInt("user_id");
	}
}
