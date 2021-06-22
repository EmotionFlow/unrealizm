package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public final class UserGroup {
	public int groupId = 0;
	public int loginUserId;
	public int userId1 = 0;
	public int userId2 = 0;
	public int userId3 = 0;

	public enum Error {
		None, AlreadyLinkedOthers, Unknown
	}
	public Error error = Error.None;

	public UserGroup(int _loginUserId) {
		loginUserId = _loginUserId;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT id, user_id_1, user_id_2, user_id_3 FROM user_groups WHERE user_id_1=? OR user_id_2=? OR user_id_3=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, loginUserId);
			statement.setInt(2, loginUserId);
			statement.setInt(3, loginUserId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				groupId = resultSet.getInt(1);
				userId1 = resultSet.getInt(2);
				userId2 = resultSet.getInt(3);
				userId3 = resultSet.getInt(4);
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
	}

	public boolean add(int addId){
		if (addId < 1) return false;
		if (addId==userId1 || addId==userId2 || addId==userId3) return true;
		if (userId1>0 && userId2>0 && userId3>0) return false;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
			String columnName = "";
			connection = DatabaseUtil.dataSource.getConnection();

			// もし、追加したいIDが他で登録済みだったら、エラーとする。
			sql = "SELECT 1 FROM user_groups WHERE" +
					" user_id_1=? OR user_id_2=? OR user_id_3=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, addId);
			statement.setInt(2, addId);
			statement.setInt(3, addId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				error = Error.AlreadyLinkedOthers;
				return false;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (groupId<1) {
				userId1 = loginUserId;
				userId2 = addId;
				sql = "INSERT INTO user_groups(user_id_1, user_id_2, user_id_3)" +
						" VALUES (?,?,0) RETURNING id";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, loginUserId);
				statement.setInt(2, addId);
				resultSet = statement.executeQuery();
				resultSet.next();
				groupId = resultSet.getInt(1);
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			} else {
				if (userId1<1) {
					userId1 = addId;
					columnName = "user_id_1";
				} else if (userId2<1) {
					userId2 = addId;
					columnName = "user_id_2";
				} else if (userId3<1) {
					userId3 = addId;
					columnName = "user_id_3";
				} else {
					return false;
				}
				sql = String.format(
						"UPDATE user_groups SET %s=%d, updated_at=now() WHERE id=%d",
						columnName, addId, groupId);
				statement = connection.prepareStatement(sql);
				statement.executeUpdate();
				statement.close();statement=null;
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	public boolean remove(int removeId){
		if (groupId<1 || removeId<1 || removeId==loginUserId) return false;

		String columnName;
		if (userId1 == removeId) {
			columnName = "user_id_1";
			userId1 = 0;
		} else if (userId2 == removeId) {
			columnName = "user_id_2";
			userId2 = 0;
		} else if (userId3 == removeId) {
			columnName = "user_id_3";
			userId3 = 0;
		} else {
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = String.format(
					"UPDATE user_groups SET %s=NULL, updated_at=now() WHERE id=%d",
					columnName, groupId);
			statement = connection.prepareStatement(sql);
			statement.executeUpdate();
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}

		return true;
	}

	public boolean contain(int userId){
		return (userId == userId1 || userId == userId2 || userId == userId3);
	}
 }
