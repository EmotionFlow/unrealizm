package jp.pipa.poipiku;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;
import java.sql.Connection;
import java.sql.PreparedStatement;

public final class RequestToStartRequesting extends Model {
	private int clientUserId = -1;
	private int creatorUserId = -1;

	public RequestToStartRequesting(){}
	public RequestToStartRequesting(int _clientUserId, int _creatorUserId){
		clientUserId = _clientUserId;
		creatorUserId = _creatorUserId;
	}

	public boolean isExists() {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		boolean result = false;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT client_user_id FROM requests_to_start_requesting WHERE client_user_id=? AND creator_user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, clientUserId);
			statement.setInt(2, creatorUserId);
			resultSet = statement.executeQuery();
			result = resultSet.next();
			errorKind = ErrorKind.None;
			resultSet.close();resultSet = null;
			statement.close();statement = null;
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.OtherError;
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return result;
	}


	public boolean insert(){
		if (clientUserId < 0 || creatorUserId < 0) {
			errorKind = ErrorKind.OtherError;
			return false;
		}
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "INSERT INTO requests_to_start_requesting VALUES(?,?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, clientUserId);
			statement.setInt(2, creatorUserId);
			statement.executeUpdate();
			statement.close();statement = null;
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.OtherError;
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return true;
	}

	public static List<Integer> select(String by, int userId){
		if (userId < 0) {
			return null;
		}
		List<Integer> list = new ArrayList<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT * FROM requests_to_start_requesting WHERE " + by + "=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(resultSet.getInt(1));
			}
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
			return null;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return list;
	}

	public static List<Integer> selectByClientUserId(int _clientUserId){
		return select("client_user_id", _clientUserId);
	}

	public static List<Integer> selectByCreatorUserId(int _creatorUserId){
		return select("creator_user_id", _creatorUserId);
	}

	public int countByCreator() {
		if (creatorUserId < 0) {
			return -1;
		}
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int cnt = -1;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT count(*) FROM requests_to_start_requesting WHERE creator_user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, creatorUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				cnt = resultSet.getInt(1);
			}
			resultSet.close();resultSet = null;
			statement.close();statement = null;
		} catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
			return -1;
		} catch (Exception e) {
			e.printStackTrace();
			return -1;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return cnt;
	}
}
