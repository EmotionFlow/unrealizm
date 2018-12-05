package jp.pipa.poipiku;

import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.Common;

public class CNotificationToken {
	public String m_strNotificationToken = "";
	public int m_nTokenType = -1;

	public CNotificationToken() {}
	public CNotificationToken(ResultSet resultSet) throws SQLException {
		m_strNotificationToken = Common.ToString(resultSet.getString("notification_token"));
		m_nTokenType = resultSet.getInt("token_type");
	}
}
