package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public final class FollowUser extends Model {
	static public final int FOLLOWING_MAX = 2000;

	public int id = -1;
	public int userId = -1;
	public int followUserId = -1;

	public boolean insert() {
		if (userId < 0 || followUserId < 0 || userId == followUserId) return false;

		boolean result = true;
		Connection connection = null;
		PreparedStatement statement = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = "INSERT INTO follows_0000(user_id, follow_user_id) VALUES (?, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2 , followUserId);
			statement.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
			result = false;
		} finally {
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return result;
	}

	public static int countFollower(int userId) {
		int cnt = 0;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = "SELECT count(*) FROM follows_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			resultSet.next();
			cnt = resultSet.getInt(1);
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {try{resultSet.close();resultSet=null;}catch (Exception e){}}
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return cnt;
	}

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
