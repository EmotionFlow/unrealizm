package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class UserWave {
	public int id = -1;
	public int fromUserId = -1;
	public int toUserId = -1;
	public String emoji = "";

	public UserWave() {}
	public UserWave(ResultSet resultSet) throws SQLException {
		id	= resultSet.getInt("id");
		fromUserId = resultSet.getInt("from_user_id");
		toUserId = resultSet.getInt("to_user_id");
		emoji = resultSet.getString("emoji");
	}


	public static List<UserWave> selectByToUserId(int toUserId, int offset, int limit) {
		List<UserWave> list = new LinkedList<>();
		final String strSql = "SELECT * FROM user_waves WHERE to_user_id=? ORDER BY created_at DESC OFFSET ? LIMIT ?";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, toUserId);
			statement.setInt(2, offset);
			statement.setInt(3, limit);
			Log.d(statement.toString());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new UserWave(resultSet));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	static public boolean insert(int fromUserId, int toUserId, String emoji, String ipAddress){
		if (toUserId < 0 || emoji==null || emoji.isEmpty()) {
			return false;
		}

		final String sql = "INSERT INTO user_waves(from_user_id, to_user_id, emoji, ip_address) VALUES (?,?,?,?)";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			int idx = 1;
			statement.setInt(idx++, fromUserId);
			statement.setInt(idx++, toUserId);
			statement.setString(idx++, emoji);
			statement.setString(idx++, ipAddress);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}

}
