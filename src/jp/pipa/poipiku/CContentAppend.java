package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import jp.pipa.poipiku.Common;

public class CContentAppend {
	public int m_nAppendId = 0;
	public int m_nContentId = 0;
	public String m_strFileName = "";
	public Timestamp m_timeUploadDate = new Timestamp(0);

	public CContentAppend() {}
	public CContentAppend(ResultSet resultSet) throws SQLException {
		m_nAppendId			= resultSet.getInt("append_id");
		m_nContentId		= resultSet.getInt("content_id");
		m_strFileName		= Common.ToString(resultSet.getString("file_name"));
		m_timeUploadDate	= resultSet.getTimestamp("upload_date");
	}
}
