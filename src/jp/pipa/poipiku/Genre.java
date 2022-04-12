package jp.pipa.poipiku;

import java.sql.*;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class Genre extends Model{
	public int genreId = -1;
	public String genreImage = "/img/default_genre.png";
	public String genreImageBg = "";
	public int createUserId = -1;
	public Timestamp updateDate = new Timestamp(0);
	public String genreName = "";
	public String genreDesc = "";
	public String genreDetail = "";
	public int contentNumTotal = -1;
	public int contentNumWeek = -1;
	public int contentNumDay = -1;
	public int favoNum = -1;

	public enum Type implements CodeEnum<Type> {
		Undefined(-1),
		Name(0),
		Description(1),
		Detail(2);
		private final int code;
		private Type(int code) {
			this.code = code;
		}

		static public Type byCode(int _code) {
			return CodeEnum.getEnum(Type.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}
	}

	public Genre() {}
	public Genre(ResultSet resultSet) throws SQLException {
		genreId			= resultSet.getInt("genre_id");
		genreImage		= Util.toString(resultSet.getString("genre_image"));
		genreImageBg	= Util.toString(resultSet.getString("genre_image_bg"));
		createUserId	= resultSet.getInt("create_user_id");
		updateDate		= resultSet.getTimestamp("update_date");
		genreName		= Util.toString(resultSet.getString("genre_name"));
		genreDesc		= Util.toString(resultSet.getString("genre_desc"));
		genreDetail		= Util.toString(resultSet.getString("genre_detail"));
		contentNumTotal	= resultSet.getInt("content_num_total");
		contentNumWeek	= resultSet.getInt("content_num_week");
		contentNumDay	= resultSet.getInt("content_num_day");
		favoNum			= resultSet.getInt("favo_num");
		if(genreImage.isEmpty()) genreImage="/img/default_genre.png";
	}

	public static Genre select(int genreId) {
		String strSql = "";
		Genre genre = new Genre();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			strSql = "SELECT * FROM genres WHERE genre_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, genreId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				genre = new Genre(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return genre;
	}

	public static Genre select(String genreName) {
		String strSql = "";
		Genre genre = new Genre();
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// Get info_list
			strSql = "SELECT * FROM genres WHERE genre_name=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, genreName);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				genre = new Genre(resultSet);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return genre;
	}

	public void update(Type type, String value) {
		final String columnName;
		if (type == Type.Description) {
			columnName = "genre_desc";
		} else if (type == Type.Detail) {
			columnName = "genre_detail";
		} else {
			return;
		}

		final String sql = "UPDATE genres SET %s=?, update_date=now() WHERE genre_id=?".formatted(columnName);
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql)
			){
			statement.setString(1, value);
			statement.setInt(2, genreId);
			statement.executeUpdate();
			if (type == Type.Description) {
				genreDesc = value;
			} else if (type == Type.Detail) {
				genreDetail = value;
			}
		}catch (SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
	}
}
