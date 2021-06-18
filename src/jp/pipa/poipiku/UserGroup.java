package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public final class UserGroup {
	public int groupId = -1;
	public int loginUserId = -1;
	int userId1 = -1;
	int userId2 = -1;
	int userId3 = -1;

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
		if (userId1>0 && userId2>0 && userId3>0) return false;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
			String columnName = "";
			connection = DatabaseUtil.dataSource.getConnection();

			// もし、追加したいIDが他で登録済みだったら、そこからIDを消す。
			sql = "SELECT id, user_id_1, user_id_2, user_id_3 FROM user_groups WHERE user_id_1=? OR user_id_2=? OR user_id_3=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, addId);
			statement.setInt(2, addId);
			statement.setInt(3, addId);
			resultSet = statement.executeQuery();

			int grpId = -1;
			if (resultSet.next()) {
				grpId = resultSet.getInt(1);
				for (int i=2; i<=4; i++) {
					if (resultSet.getInt(i) == addId) {
						columnName = "user_id_" + (i-1);
						break;
					}
				}
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (grpId>0 && columnName.isEmpty()) {
				sql = String.format(
						"UPDATE user_groups SET %s=NULL updated_at=now() WHERE id=%d",
						columnName, addId);
				statement = connection.prepareStatement(sql);
				statement.executeUpdate();
				statement.close();
			}

			if (groupId<0) {
				userId1 = loginUserId;
				userId2 = addId;
				sql = "INSERT INTO user_groups(user_id_1, user_id_2, user_id_3)" +
						" VALUES (?,?,NULL)";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, loginUserId);
				statement.setInt(2, addId);
				statement.executeUpdate();
				statement.close();
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

	public boolean remove(int userId){
		if (groupId<0 || userId<0) return false;

		String columnName;
		if (userId1 == userId) {
			columnName = "user_id_1";
		} else if (userId2 == userId) {
			columnName = "user_id_2";
		} else if (userId3 == userId) {
			columnName = "user_id_3";
		} else {
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
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
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}


		return false;
	}
}
