package jp.pipa.poipiku;

import jp.pipa.poipiku.settlement.epsilon.User;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;

public final class UserWaveTemplate extends Model {
	public static final boolean WAVE_DEFAULT = true;
	public static final boolean COMMENT_DEFAULT = false;

	public static final String DISABLE_WAVE_CHAR = "disable";
	public static final int DISABLE_WAVE_ORDER = -1;
	public static final String ENABLE_WAVE_COMMENT_CHAR = "enableComment";
	public static final int ENABLE_WAVE_COMMENT_ORDER = -2;

	public int id = -1;
	public int userId = -1;
	public String chars = "";
	public int dispOrder = -99;

	public UserWaveTemplate(){};

	public UserWaveTemplate(final ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	private void set(final ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		userId = resultSet.getInt("user_id");
		chars = resultSet.getString("chars");
		dispOrder = resultSet.getInt("disp_order");
	}

	static public List<UserWaveTemplate> select(int userId) {
		final String sql = """
			SELECT *
			FROM user_wave_templates
			WHERE user_id=? ORDER BY disp_order
			""";
		List<UserWaveTemplate> list = new LinkedList<>();
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				UserWaveTemplate waveTemplate = new UserWaveTemplate(resultSet);
				list.add(waveTemplate);
				if (!waveTemplate.isEnabled()) break;
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return list;
	}

	static public List<UserWaveTemplate> selectAll(int userId) {
		final String sql = """
			SELECT *
			FROM user_wave_templates
			WHERE user_id=? ORDER BY disp_order
			""";
		List<UserWaveTemplate> list = new LinkedList<>();
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				list.add(new UserWaveTemplate(resultSet));
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return list;
	}

	static public UserWaveTemplate select(int userId, int dispOrder) {
		final String sql = """
			SELECT *
			FROM user_wave_templates
			WHERE user_id=? AND disp_order=?
			""";
		UserWaveTemplate wave = null;
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			statement.setInt(2, dispOrder);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				wave = new UserWaveTemplate(resultSet);
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return wave;
	}

	static public boolean upsert(int userId, int dispOrder, String chars){
		if (userId < 0 || dispOrder < -2) {
			return false;
		}
		if (chars==null || chars.isEmpty()) {
			Log.d("invalid chars");
			return false;
		}

		final String sql = """
			INSERT INTO user_wave_templates(user_id, disp_order, chars) VALUES (?,?,?)
			ON CONFLICT ON CONSTRAINT user_wave_templates_pkey
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

	static public boolean delete(int userId, int dispOrder) {
		if (userId < 0 || dispOrder < -2) return false;
		final String sql = """
			DELETE FROM user_wave_templates
			WHERE user_id=? AND disp_order=?
			""";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			statement.setInt(2, dispOrder);
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
			DELETE FROM user_wave_templates
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

	static public boolean disable(int userId) {
		if (userId < 0) return false;
		return upsert(userId, DISABLE_WAVE_ORDER, DISABLE_WAVE_CHAR);
	}

	static public boolean enable(int userId) {
		if (userId < 0) return false;
		return delete(userId, DISABLE_WAVE_ORDER);
	}

	static public boolean disableComment(int userId) {
		if (userId < 0) return false;
		return delete(userId, ENABLE_WAVE_COMMENT_ORDER);
	}

	static public boolean enableComment(int userId) {
		if (userId < 0) return false;
		return upsert(userId, ENABLE_WAVE_COMMENT_ORDER, ENABLE_WAVE_COMMENT_CHAR);
	}

	public boolean isEnabled() {
		if (dispOrder == DISABLE_WAVE_ORDER) {
			return false;
		}
		return true;
	}

	static public boolean isEnabled(List<UserWaveTemplate> list) {
		boolean result = true;
		for (UserWaveTemplate t: list) {
			if (!t.isEnabled()) {
				result = false;
				break;
			}
		}
		return result;
	}

	public boolean isCommentEnabled() {
		if (dispOrder == ENABLE_WAVE_COMMENT_ORDER) {
			return true;
		}
		return false;
	}

	static public boolean isCommentEnabled(List<UserWaveTemplate> list) {
		boolean result = false;
		for (UserWaveTemplate t: list) {
			Log.d("dispOrder %d".formatted(t.dispOrder));
			if (t.isCommentEnabled()) {
				result = true;
				break;
			}
		}
		return result;
	}

}
