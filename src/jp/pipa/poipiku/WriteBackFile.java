package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public final class WriteBackFile extends Model{
	public ErrorKind errorKind = ErrorKind.Undefined;

	public enum TableCode implements CodeEnum<TableCode> {
		Undefined(-1),
		Contents(0),
		ContentsAppends(1);
		static public TableCode byCode(int _code) {
			return CodeEnum.getEnum(TableCode.class, _code);
		}
		@Override
		public int getCode() {
			return code;
		}
		private final int code;
		private TableCode(int code) {
			this.code = code;
		}
	}
	public enum Status implements CodeEnum<Status> {
		Undefined(-1),
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
	public TableCode tableCode = TableCode.Undefined;
	public int rowId = -1;
	public Status status = Status.Undefined;
	public String path = "";
	public Timestamp createdAt = null;
	public Timestamp updatedAt = null;

	public WriteBackFile() {}
	public WriteBackFile(ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	public void set(ResultSet resultSet) throws SQLException {
		userId = resultSet.getInt("user_id");
		tableCode = TableCode.byCode(resultSet.getInt("table_code"));
		rowId = resultSet.getInt("row_id");
		status = Status.byCode(resultSet.getInt("status"));
		path = resultSet.getString("path");
		createdAt = resultSet.getTimestamp("created_at");
		updatedAt = resultSet.getTimestamp("updated_at");
	}

	public boolean insert() {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "INSERT INTO write_back_files(user_id, table_code, row_id, path) VALUES (?,?,?,?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, tableCode.getCode());
			statement.setInt(3, rowId);
			statement.setString(4, path);
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

	public boolean delete() {
		if (rowId<0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "DELETE FROM write_back_files WHERE table_code=? AND row_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, tableCode.getCode());
			statement.setInt(2, rowId);
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

	public boolean updateStatus(Status newStatus) {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE write_back_files SET status=?, updated_at=now() WHERE table_code=? AND row_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, newStatus.getCode());
			statement.setInt(2, tableCode.getCode());
			statement.setInt(3, rowId);
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

	static public List<WriteBackFile> select(Status _status, int hoursBefore) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<WriteBackFile> list = new ArrayList<>();
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = String.format("SELECT * FROM write_back_files WHERE status=? AND created_at < now() - INTERVAL '%d hours'", hoursBefore);
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _status.getCode());
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new WriteBackFile(resultSet));
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

	static public boolean deleteByStatus(Status _status, int hoursBefore) {
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = String.format("DELETE FROM write_back_files WHERE status=? AND updated_at < now() - INTERVAL '%d hours'", hoursBefore);
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _status.getCode());
			statement.executeUpdate();
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

	static public boolean deleteByUserId(int userId) {
		if (userId < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "DELETE FROM write_back_files WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.executeUpdate();
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

	static public boolean deleteByPrimaryKeys(TableCode _tableCode, int _rowId) {
		if (_rowId < 0) return false;
		Connection connection = null;
		PreparedStatement statement = null;
		String sql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "DELETE FROM write_back_files WHERE table_code=? AND row_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _tableCode.getCode());
			statement.setInt(2, _rowId);
			statement.executeUpdate();
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
}
