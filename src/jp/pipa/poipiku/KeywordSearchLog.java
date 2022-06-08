package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;

public final class KeywordSearchLog extends Model {

	public int id = -1;
	public int userId = -1;
	public String keywords = "";
	public String muteWords = "";
	public int page = -1;
	public boolean isHide = false;
	public int resultNum = -1;
	public String ipAddress = "";


	public enum SearchTarget implements CodeEnum<SearchTarget> {
		Undefined(-1),
		Contents(0),
		Tags(1),
		Users(2);

		private final int code;
		private SearchTarget(int code) {
			this.code = code;
		}

		@Override
		public int getCode() {
			return code;
		}
	}
	public SearchTarget searchTarget = SearchTarget.Undefined;


	public KeywordSearchLog(){};

	public KeywordSearchLog(final ResultSet resultSet) throws SQLException {
		set(resultSet);
	}

	private void set(final ResultSet resultSet) throws SQLException {
		id = resultSet.getInt("id");
		userId = resultSet.getInt("user_id");
		keywords = resultSet.getString("keywords");
		muteWords = resultSet.getString("mute_words");
		page = resultSet.getInt("page");
		isHide = resultSet.getBoolean("is_hide");
		resultNum = resultSet.getInt("result_num");
	}

	static public List<KeywordSearchLog> selectByUserId(int userId) {
		final String sql = """
			SELECT *
			FROM keyword_search_logs
			WHERE user_id=? ORDER BY id DESC
			""";
		List<KeywordSearchLog> list = new LinkedList<>();
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, userId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				KeywordSearchLog keywordSearchLog = new KeywordSearchLog(resultSet);
				list.add(keywordSearchLog);
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return list;
	}

	static public boolean insert(int _userId, String _keywords, String _muteWords, int _page, SearchTarget _searchTarget, int _resultNum, String _ipAddress) {
		if (_keywords == null || _keywords.isEmpty() || _searchTarget == SearchTarget.Undefined) return false;
		final String sql = """
			INSERT INTO keyword_search_logs(user_id, search_target_code, keywords, mute_words, page, result_num, ip_address)
			VALUES (?,?,?,?,?,?,?)
			""";
		try (
				Connection connection = DatabaseUtil.dataSource.getConnection();
				PreparedStatement statement = connection.prepareStatement(sql);
		) {
			int idx=1;
			statement.setInt(idx++, _userId);
			statement.setInt(idx++, _searchTarget.getCode());
			statement.setString(idx++, _keywords);
			statement.setString(idx++, _muteWords==null?"":_muteWords);
			statement.setInt(idx++, _page);
			statement.setInt(idx++, _resultNum);
			statement.setString(idx++, _ipAddress);
			statement.executeUpdate();
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return true;
	}
}
