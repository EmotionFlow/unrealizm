package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class FollowUser extends Model {
	static public final int FOLLOWING_MAX = 2000;

	// 自分がフォローしている人リスト
	public static List<Integer> selectFollowerList (int userId) {
		List<Integer> list = new ArrayList<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = "SELECT user_id FROM follows_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add( resultSet.getInt(1));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {try{resultSet.close();resultSet=null;}catch (Exception e){}}
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return list;
	}

	// 自分をフォローしている人リスト
	public static List<Integer> selectFollowToMeList (int userId) {
		List<Integer> list = new ArrayList<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = "SELECT user_id FROM follows_0000 WHERE follow_user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add( resultSet.getInt(1));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {try{resultSet.close();resultSet=null;}catch (Exception e){}}
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return list;
	}
}
