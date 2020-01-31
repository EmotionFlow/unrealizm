package jp.pipa.poipiku.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jp.pipa.poipiku.*;

public class SqlUtil {
	public static String getBlockUserSql(Connection connection, int nUserId) throws SQLException {
		String strRet = "";
		String sql = "SELECT block_user_id FROM blocks_0000 WHERE user_id=? LIMIT 1";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, nUserId);
		ResultSet resultSet = statement.executeQuery();
		if(resultSet.next()) {
			strRet = " AND users_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?)";
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return strRet;
	}

	public static String getBlockedUserSql(Connection connection, int nUserId) throws SQLException {
		String strRet = "";
		String sql = "SELECT user_id FROM blocks_0000 WHERE block_user_id=? LIMIT 1";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, nUserId);
		ResultSet resultSet = statement.executeQuery();
		if(resultSet.next()) {
			strRet = " AND users_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)";
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return strRet;
	}

	public static String getSearhKeyWord(Connection connection, int nUserId) throws SQLException {
		String sql = "SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=1 LIMIT 100";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, nUserId);
		ResultSet resultSet = statement.executeQuery();
		StringBuilder sbKeyWord = new StringBuilder();
		if(resultSet.next()) {
			sbKeyWord.append(Common.ToString(resultSet.getString(1)).trim());
			while (resultSet.next()) {
				sbKeyWord.append(" OR ");
				sbKeyWord.append(Common.ToString(resultSet.getString(1)).trim());
			}
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return sbKeyWord.toString().trim();
	}

	public static String getMuteKeyWord(Connection connection, int nUserId) throws SQLException {
		String strRet = "";
		String sql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setInt(1, nUserId);
		ResultSet resultSet = statement.executeQuery();
		if(resultSet.next()) {
			strRet = Common.ToString(resultSet.getString(1)).trim();
		}
		resultSet.close();resultSet=null;
		statement.close();statement=null;
		return strRet.trim();
	}

	public static String getMuteKeyWordNega(Connection connection, int nUserId) throws SQLException {
		String strRet = getMuteKeyWord(connection, nUserId);
		if(!strRet.isEmpty()) {
			strRet = " -" + strRet.replace(" OR ", " -");
		}
		return strRet;
	}
}
