package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.Common;

public class CTag {
	public int m_nTagId = -1;
	public String m_strTagTxt = "";
	public int m_nTypeId = -1;

	public CTag() {}
	public CTag(ResultSet resultSet) throws SQLException {
		m_strTagTxt = Common.ToString(resultSet.getString("tag_txt"));
	}
}
