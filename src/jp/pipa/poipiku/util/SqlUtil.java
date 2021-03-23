package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class SqlUtil {
	public static String getMuteKeyWord(Connection connection, int userId) throws SQLException {
		String strRet = "";
		String sql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		ResultSet resultSet = statement.executeQuery();
		if(resultSet.next()) {
			strRet = Util.toString(resultSet.getString(1)).trim();
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return strRet.trim();
	}

	public static boolean hasBlockUser(Connection connection, int userId) throws SQLException {
		if(userId<=0) return false;
		boolean bRet = false;
		String sql = "SELECT block_user_id FROM blocks_0000 WHERE user_id=? limit 1";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		ResultSet resultSet = statement.executeQuery();
		bRet = resultSet.next();
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return bRet;
	}

	public static boolean hasBlockedUser(Connection connection, int userId) throws SQLException {
		if(userId<=0) return false;
		boolean bRet = false;
		String sql = "SELECT user_id FROM blocks_0000 WHERE block_user_id=? limit 1";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		ResultSet resultSet = statement.executeQuery();
		bRet = resultSet.next();
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return bRet;
	}

	public static void setNullOrInt(PreparedStatement statement, int index, Integer i) throws SQLException{
		if (i == null) {
			statement.setNull(index, java.sql.Types.NULL);
		} else {
			statement.setInt(index, i);
		}
	}
}
