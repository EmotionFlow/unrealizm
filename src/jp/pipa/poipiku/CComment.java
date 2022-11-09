package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import jp.pipa.poipiku.util.Util;

public class CComment {
	public int m_nCommentId = 0;
	public int m_nContentId = 0;
	public String m_strDescription = "";
	public int m_nUserId = 0;
	public Timestamp m_timeUploadDate = new Timestamp(0);

	public String m_strNickName = "";
	public String m_strFileName = "";

	public CComment() {}
	public CComment(ResultSet resultSet) throws SQLException {
		m_nCommentId		= resultSet.getInt("comment_id");
		m_nContentId		= resultSet.getInt("content_id");
		m_strDescription	= Util.toString(resultSet.getString("description"));
		m_nUserId			= resultSet.getInt("user_id");
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
	}
}
