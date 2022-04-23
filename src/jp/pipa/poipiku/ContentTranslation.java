package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ContentTranslation {
	public int contentId = -1;

	public static final int LANG_DEFAULT = -1;
	public int langId = LANG_DEFAULT;

	public CContent.ColumnType columnType = CContent.ColumnType.Undefined;

	public String transTxt = "";

	public ContentTranslation() {}
	public ContentTranslation(ResultSet resultSet) throws SQLException {
		contentId	= resultSet.getInt("content_id");
		langId = resultSet.getInt("lang_id");
		columnType = CContent.ColumnType.byCode(resultSet.getInt("type_id"));
		transTxt = resultSet.getString("trans_text");
	}

	public static ContentTranslation select(int contentId, int langId, CContent.ColumnType columnType) {
		ContentTranslation translation = null;
		final String strSql = "SELECT * FROM content_translations WHERE content_id=? AND lang_id=? AND type_id=?";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, contentId);
			statement.setInt(2, langId);
			statement.setInt(3, columnType.getCode());
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				translation = new ContentTranslation(resultSet);
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return translation;
	}

	public static List<ContentTranslation> select(int contentId) {
		List<ContentTranslation> list = new ArrayList<>();
		final String strSql = "SELECT * FROM content_translations WHERE content_id=?";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, contentId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new ContentTranslation(resultSet));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	public static List<ContentTranslation> select(int contentId, CContent.ColumnType columnType) {
		List<ContentTranslation> list = new ArrayList<>();
		final String strSql = "SELECT * FROM content_translations WHERE content_id=? AND type_id=? ORDER BY lang_id";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(strSql);
		) {
			statement.setInt(1, contentId);
			statement.setInt(2, columnType.getCode());
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new ContentTranslation(resultSet));
			}
			resultSet.close();
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		}
		return list;
	}

	static public boolean upsert(int contentId, int lang_id, CContent.ColumnType columnType, String transTxt, int userId){
		if (userId < 0 || columnType == null || columnType == CContent.ColumnType.Undefined) {
			return false;
		}

		final String sql = """
			INSERT INTO content_translations(content_id, type_id, lang_id, trans_text, last_update_user_id) VALUES (?,?,?,?,?)
			ON CONFLICT ON CONSTRAINT content_translations_pkey
			DO UPDATE SET trans_text=?, last_update_user_id=?, updated_at=now()
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			int idx = 1;
			statement.setInt(idx++, contentId);
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
