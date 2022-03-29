package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class CommentTemplate extends Model {
	public int id = -1;
	public int userId = -1;
	public String chars = "";
	public int dispOrder = 0;

	public CommentTemplate(){};

	public CommentTemplate(final ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	private void set(final ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		userId = resultSet.getInt("user_id");
		chars = resultSet.getString("chars");
		dispOrder = resultSet.getInt("disp_order");
	}

	public boolean select(int userId, int dispOrder) {
		boolean result = false;
		final String sql = """
			SELECT *
			FROM comment_templates
			WHERE user_id=? AND disp_order=?
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			statement.setInt(2, dispOrder);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				set(resultSet);
				result = true;
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return result;
	}

	static public boolean upsert(int userId, int dispOrder, String chars){
		if (userId < 0 || dispOrder < 0) {
			return false;
		}
		if (chars==null || chars.isEmpty()) {
			Log.d("invalid chars");
			return false;
		}

		final String sql = """
			INSERT INTO comment_templates(user_id, disp_order, chars) VALUES (?,?,?)
			ON CONFLICT ON CONSTRAINT comment_templates_pkey
			DO UPDATE SET chars=?, updated_at=now()
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			statement.setInt(2, dispOrder);
			statement.setString(3, chars);
			statement.setString(4, chars);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}

	static public boolean deleteByUserId(int userId){
		if (userId < 0) return false;

		final String sql = """
			DELETE FROM comment_templates
			WHERE user_id=?
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}
 }
