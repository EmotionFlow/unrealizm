package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class GenreTranslation {
	public int genreId = -1;

	public static final int LANG_DEFAULT = -1;
	public int langId = LANG_DEFAULT;

	public Genre.Type type = Genre.Type.Undefined;

	public String transTxt = "";

	public GenreTranslation() {}
	public GenreTranslation(ResultSet resultSet) throws SQLException {
		genreId	= resultSet.getInt("genre_id");
		langId = resultSet.getInt("lang_id");
		type = Genre.Type.byCode(resultSet.getInt("type_id"));
		transTxt = resultSet.getString("trans_text");
	}

	public static GenreTranslation select(int genreId, int langId, Genre.Type type) {
		GenreTranslation translation = null;
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=? AND lang_id=? AND type_id=?";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			statement.setInt(2, langId);
			statement.setInt(3, type.getCode());
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				translation = new GenreTranslation(resultSet);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return translation;
	}

	public static List<GenreTranslation> select(int genreId) {
		List<GenreTranslation> list = new ArrayList<>();
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=?";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			Log.d(statement.toString());
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

	static public boolean upsert(int genreId, int lang_id, Genre.Type type, String transTxt, int userId){
		if (userId < 0 || type == null || type == Genre.Type.Undefined) {
			return false;
		}

		final String sql = """
			INSERT INTO genre_translations(genre_id, type_id, lang_id, trans_text, last_udpate_user_id) VALUES (?,?,?,?,?)
			ON CONFLICT ON CONSTRAINT genre_translations_pkey
			DO UPDATE SET trans_text=?, last_udpate_user_id=?, updated_at=now()
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			int idx = 1;
			statement.setInt(idx++, genreId);
			statement.setInt(idx++, type.getCode());
			statement.setInt(idx++, lang_id);
			statement.setString(idx++, transTxt);
			statement.setInt(idx++, userId);
			statement.setString(idx++, transTxt);
			statement.setInt(idx++, userId);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}

}
