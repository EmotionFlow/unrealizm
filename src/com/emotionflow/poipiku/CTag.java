package com.emotionflow.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

public class CTag {
	public String m_strTagTxt = "";

	public CTag() {}
	public CTag(ResultSet resultSet) throws SQLException {
		m_strTagTxt = Common.ToString(resultSet.getString("tag_txt"));
	}
}
