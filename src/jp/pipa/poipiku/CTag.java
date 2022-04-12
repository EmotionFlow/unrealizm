package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.util.Util;

public class CTag {
	public int m_nTagId = -1;
	public String m_strTagTxt = "";
	public String m_strTagTransTxt = "";
	public int m_nTypeId = -1;
	public int m_nGenreId = -1;
	public boolean isFollow = false;

	public CTag() {}
	public CTag(ResultSet resultSet) throws SQLException {
		m_strTagTxt = Util.toString(resultSet.getString("tag_txt"));
	}
}
