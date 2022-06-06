package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.CodeEnum;
import jp.pipa.poipiku.Model;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public final class TmpUser extends Model {
	public ErrorKind errorKind = ErrorKind.Undefined;

	public enum Status implements CodeEnum<Status> {
		Created(0),
		Moving(1),
		Moved(2),
		ErrorOccurred(-99);
		static public Status byCode(int _code) {
			return CodeEnum.getEnum(Status.class, _code);
		}
		@Override
		public int getCode() {
			return code;
		}
		private final int code;
		private Status(int code) {
			this.code = code;
		}
	}

	public int userId = -1;
	public Status status = Status.Created;

	public TmpUser() {}
	public TmpUser(ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	public void set(ResultSet resultSet) throws SQLException {
		userId = resultSet.getInt("user_id");
		status = Status.byCode(resultSet.getInt("status"));
	}
	
	public boolean updateStatus(Status newStatus) {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE tmp_users SET status=?, last_updated_at=now() WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, newStatus.getCode());
			statement.setInt(2, userId);
			statement.executeUpdate();
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return true;
	}

	static public List<TmpUser> select(Status _status, int limit) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<TmpUser> list = new ArrayList<>();
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT * FROM tmp_users WHERE status=? order by user_id limit ?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _status.getCode());
			statement.setInt(2, limit);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new TmpUser(resultSet));
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return null;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return list;
	}

	static public List<TmpUser> selectByUserId(Status _status, int _userId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<TmpUser> list = new ArrayList<>();
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT * FROM tmp_users WHERE status=? AND user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _status.getCode());
			statement.setInt(2, _userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new TmpUser(resultSet));
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			return null;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return list;
	}
}
