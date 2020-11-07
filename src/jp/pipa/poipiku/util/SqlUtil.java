package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class SqlUtil {
	public static String getMuteKeyWord(Connection connection, int nUserId) throws SQLException {
		String strRet = "";
		String sql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, nUserId);
		ResultSet resultSet = statement.executeQuery();
		if(resultSet.next()) {
			strRet = Util.toString(resultSet.getString(1)).trim();
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return strRet.trim();
	}
}
