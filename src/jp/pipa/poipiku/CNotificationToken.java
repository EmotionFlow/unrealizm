package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.util.Util;

public class CNotificationToken {
	public String m_strNotificationToken = "";
	public int m_nTokenType = -1;

	public CNotificationToken() {}
	public CNotificationToken(ResultSet resultSet) throws SQLException {
		m_strNotificationToken = Util.toString(resultSet.getString("notification_token"));
		m_nTokenType = resultSet.getInt("token_type");
	}
}
