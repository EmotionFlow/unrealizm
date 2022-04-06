package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GenreTranslation {
	public int genreId = -1;

	public static final int LANG_DEFAULT = -1;
	public int langId = LANG_DEFAULT;

	public String transName = "";
	public String transDesc = "";
	public String transDetail = "";

	public GenreTranslation() {}
	public GenreTranslation(ResultSet resultSet) throws SQLException {
		genreId	= resultSet.getInt("genre_id");
		langId = resultSet.getInt("lang_id");
		transName = resultSet.getString("trans_name");
		transDesc = resultSet.getString("trans_desc");
		transDetail = resultSet.getString("trans_detail");
	}

	public static GenreTranslation select(int genreId, int langId) {
		GenreTranslation genre = null;
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=? AND lang_id=?";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			statement.setInt(2, langId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				genre = new GenreTranslation(resultSet);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return genre;
	}

	public static List<GenreTranslation> select(int genreId) {
		List<GenreTranslation> list = new ArrayList<>();
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=?";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new GenreTranslation(resultSet));
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	static public boolean upsert(int genreId, int lang_id, String columnName, String txt, int userId){
		if (userId < 0) {
			return false;
		}

		final String sql = """
			INSERT INTO genre_translations(genre_id, lang_id, %s) VALUES (?,?,?)
			ON CONFLICT ON CONSTRAINT genre_translations_pkey
			DO UPDATE SET %s=?, updated_at=now()
			""".formatted(columnName, columnName);
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, genreId);
			statement.setInt(2, lang_id);
			statement.setString(3, txt);
			statement.setString(4, txt);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}

}
