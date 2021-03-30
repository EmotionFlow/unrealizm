package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;

import java.sql.*;

public final class InfoList extends Model{
	public int userId;
	public int contentId = -1;
	public int contentType;
	public int infoType;
	public String infoThumb = "";
	public String infoDesc;
	public Timestamp infoDate;
	public int badgeNum;
	public boolean hadRead;
	public int requestId = -1;

	public InfoList(){}
	public InfoList(final ResultSet resultSet) throws SQLException{
		set(resultSet);
	}

	public void set(final ResultSet resultSet) throws SQLException {
		userId = resultSet.getInt("user_id");
		contentId = resultSet.getInt("content_id");
		contentType = resultSet.getInt("content_type");
		infoType = resultSet.getInt("info_type");
		infoThumb = resultSet.getString("info_thumb");
		infoDesc = resultSet.getString("info_desc");
		infoDate = resultSet.getTimestamp("info_date");
		badgeNum = resultSet.getInt("badge_num");
		hadRead = resultSet.getBoolean("had_read");
		requestId = resultSet.getInt("request_id");
	}

	public boolean insert() {
		Connection connection = null;
		PreparedStatement statement = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql =
					"INSERT INTO info_lists(" +
							"user_id, content_id, content_type, " +
							"info_type, info_thumb, info_desc, info_date, badge_num, request_id)"
					+ " VALUES(?, ?, ?, ?, ?, ?, current_timestamp, ?, ?)";
			statement = connection.prepareStatement(sql);
			int idx = 1;
			statement.setInt(idx++, userId);
			statement.setInt(idx++, contentId);
			statement.setInt(idx++, contentType);
			statement.setInt(idx++, infoType);
			statement.setString(idx++, infoThumb);
			statement.setString(idx++, infoDesc);
			statement.setInt(idx++, badgeNum);
			statement.setInt(idx++, requestId);
			statement.executeUpdate();
			errorKind = ErrorKind.None;
		} catch (SQLException sqlException) {
			sqlException.printStackTrace();
			errorKind = ErrorKind.DbError;
			return false;
		} finally {
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return true;

	}



}