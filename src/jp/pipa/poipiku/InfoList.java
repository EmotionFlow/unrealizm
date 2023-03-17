package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.HashMap;

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

	public enum ContentType implements CodeEnum<ContentType> {
		Undefined(0),
		Image(1),
		Text(2);

		static public ContentType byCode(int _code) {
			return CodeEnum.getEnum(ContentType.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private ContentType(int code) {
			this.code = code;
		}
	}

	public enum InfoType implements CodeEnum<InfoType> {
		Undefined(-1),
		Emoji(1),
		Request(3),
		Gift(4),
		RequestStarted(5),
		EmojiReply(6),
		WaveEmoji(7),
		WaveEmojiMessage(8),
		WaveEmojiMessageReply(9);

		static public InfoType byCode(int _code) {
			return CodeEnum.getEnum(InfoType.class, _code);
		}

		@Override
		public final int getCode() {
			return code;
		}

		private final int code;
		private InfoType(int code) {
			this.code = code;
		}
	}


	private static String INSERT_SQL =
			"INSERT INTO info_lists(" +
			" user_id, content_id, content_type, " +
			" info_type, info_thumb, info_desc, info_date, badge_num, request_id)" +
			" VALUES(?, ?, ?, ?, ?, ?, current_timestamp, ?, ?)";

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

	public boolean upsert() {
		Connection connection = null;
		PreparedStatement statement = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = INSERT_SQL +
					" ON CONFLICT ON CONSTRAINT info_lists_pkey DO UPDATE" +
					" SET info_desc=?, info_date=current_timestamp, badge_num=?, had_read=false";
			statement = connection.prepareStatement(sql);

			int idx = 1;

			// insert
			statement.setInt(idx++, userId);
			statement.setInt(idx++, contentId);
			statement.setInt(idx++, contentType);
			statement.setInt(idx++, infoType);
			statement.setString(idx++, infoThumb);
			statement.setString(idx++, infoDesc);
			statement.setInt(idx++, badgeNum);
			statement.setInt(idx++, requestId);

			// update
			statement.setString(idx++, infoDesc);
			statement.setInt(idx++, badgeNum);

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

	public boolean tryInsert() {
		Connection connection = null;
		PreparedStatement statement = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = INSERT_SQL +
							" ON CONFLICT ON CONSTRAINT info_lists_pkey DO NOTHING";
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

	public boolean insert() {
		Connection connection = null;
		PreparedStatement statement = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = INSERT_SQL;
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

	public boolean insertBeforeResetTransaction() {
		Connection connection = null;
		PreparedStatement statement = null;
		String strSql = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			// 確認済みお知らせだった場合、通知絵文字一覧をリセット
			connection.setAutoCommit(false);
			strSql = "DELETE FROM info_lists WHERE user_id=? AND content_id=? AND info_type=? AND had_read=true;";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			statement.setInt(3, infoType);
			statement.executeUpdate();
			statement.close();statement=null;

			// お知らせ一覧に追加
			strSql = "INSERT INTO info_lists(user_id, content_id, content_type, info_type, info_thumb, info_desc) "
					+ "VALUES(?, ?, ?, ?, ?, ?) "
					+ "ON CONFLICT ON CONSTRAINT info_lists_pkey "
					+ "DO UPDATE SET "
					+ "info_desc=(COALESCE(info_lists.info_desc, '') || ?), "
					+ "info_date=CURRENT_TIMESTAMP, "
					+ "badge_num=(info_lists.badge_num+1), "
					+ "had_read=false;";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, contentId);
			statement.setInt(3, contentType);
			statement.setInt(4, infoType);
			statement.setString(5, infoThumb);
			statement.setString(6, infoDesc);
			statement.setString(7, infoDesc);
			statement.executeUpdate();
			connection.commit();
			connection.setAutoCommit(true);
			statement.close();statement=null;
		} catch (SQLException sqlException) {
			Log.d("transaction fail");
			Log.d(strSql);
			sqlException.printStackTrace();
			try {
				connection.rollback();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return false;
		} finally {
			try {
				connection.setAutoCommit(true);
				connection.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return true;
	}

	static public int selectUnreadBadgeSum(final int userId) {
		return InfoList.selectUnreadBadgeSum(userId, null);
	}

	static public int selectUnreadBadgeSum(final int userId, Connection _connection) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		int badgeNum = -1;
		try {
			if (_connection == null) {
				connection = DatabaseUtil.dataSource.getConnection();
			} else {
				connection = _connection;
			}
			final String sql = "SELECT SUM(badge_num) FROM info_lists WHERE user_id=? AND had_read=false";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				badgeNum = resultSet.getInt(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {try{resultSet.close();resultSet=null;}catch (Exception e){}}
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (_connection == null && connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return badgeNum;
	}

	static public HashMap<InfoType, Integer> selectUnreadNumByInfoType(int userId){
		HashMap<InfoType, Integer> hashMap = new HashMap<>();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			final String sql = "select info_type, count(info_type) info_num from info_lists where user_id=? and had_read=false group by info_type";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				final InfoType infoType = InfoType.byCode(resultSet.getInt("info_type"));
				hashMap.put(infoType, resultSet.getInt("info_num"));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			if (resultSet != null) {try{resultSet.close();resultSet=null;}catch (Exception e){}}
			if (statement != null) {try{statement.close();statement=null;}catch (Exception e){}}
			if (connection != null) {try{connection.close();connection=null;}catch (Exception e){}}
		}
		return hashMap;
	}
}
