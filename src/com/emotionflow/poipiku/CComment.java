package com.emotionflow.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import com.emotionflow.poipiku.Common;

public class CComment {
	public static final int TYPE_COMMENT = 0;
	public static final int TYPE_FOLLOW = 1;
	public static final int TYPE_HEART = 2;

	public int m_nCommentId = 0;
	public int m_nContentId = 0;
	public String m_strDescription = "";
	public int m_nUserId = 0;
	public Timestamp m_timeUploadDate = new Timestamp(0);
	public int m_nToUserId = 0;

	public String m_strNickName = "";
	public String m_strFileName = "";
	public String m_strToNickName = "";
	public int m_nCommentType = TYPE_COMMENT;

	public CComment() {}
	public CComment(ResultSet resultSet) throws SQLException {
		m_nCommentId		= resultSet.getInt("comment_id");
		m_nContentId		= resultSet.getInt("content_id");
		m_strDescription	= Common.ToString(resultSet.getString("description"));
		m_nUserId			= resultSet.getInt("user_id");
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
		//m_nToUserId			= resultSet.getInt("to_user_id");
	}
}
