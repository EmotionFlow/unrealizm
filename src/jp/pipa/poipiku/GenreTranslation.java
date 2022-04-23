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

	public Genre.ColumnType columnType = Genre.ColumnType.Undefined;

	public String transTxt = "";

	public GenreTranslation() {}
	public GenreTranslation(ResultSet resultSet) throws SQLException {
		genreId	= resultSet.getInt("genre_id");
		langId = resultSet.getInt("lang_id");
		columnType = Genre.ColumnType.byCode(resultSet.getInt("type_id"));
		transTxt = resultSet.getString("trans_text");
	}

	public static GenreTranslation select(int genreId, int langId, Genre.ColumnType columnType) {
		GenreTranslation translation = null;
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=? AND lang_id=? AND type_id=?";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			statement.setInt(2, langId);
			statement.setInt(3, columnType.getCode());
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				translation = new GenreTranslation(resultSet);
			}
			resultSet.close();
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
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new GenreTranslation(resultSet));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	public static List<GenreTranslation> select(int genreId, Genre.ColumnType columnType) {
		List<GenreTranslation> list = new ArrayList<>();
		final String strSql = "SELECT * FROM genre_translations WHERE genre_id=? AND type_id=? ORDER BY lang_id";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, genreId);
			statement.setInt(2, columnType.getCode());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new GenreTranslation(resultSet));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	static public boolean upsert(int genreId, int lang_id, Genre.ColumnType columnType, String transTxt, int userId){
		if (userId < 0 || columnType == null || columnType == Genre.ColumnType.Undefined) {
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
			statement.setInt(idx++, columnType.getCode());
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
