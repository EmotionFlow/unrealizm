package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.List;

public class CheckNgSearchLog extends Batch {
	private static final int limit = 1000;

	public static void main(String[] args) {
		Log.d("CheckNgSearchLog batch start");
		int result = -1;

		// NGワードを取得
		List<String> ngWords = new ArrayList<>();
		String sql = "SELECT word FROM ng_words ORDER BY id";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				ngWords.add(resultSet.getString("word"));
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		if (ngWords.size() <= 0) {
			Log.d("No NG word is registered. Set up ng_words table.");
			return;
		}
		String ngPattern = String.join(" OR ", ngWords);

		// NG判定対象の検索ログにフラグ立て
		sql = "UPDATE keyword_search_logs SET ng=-1 WHERE id IN (SELECT id FROM keyword_search_logs WHERE ng = -2 LIMIT ?)";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setInt(1, limit);
			result = statement.executeUpdate();
			Log.d("NG check target: " + String.valueOf(result) + " rows.");
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}

		// NG未判定の検索ログに対してNG判定
		sql = "UPDATE keyword_search_logs SET ng=1 WHERE ng = -1 AND keywords &@~ '" + ngPattern + "'";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			result = statement.executeUpdate();
			Log.d("Labeled " + String.valueOf(result) + " rows as NG.");
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}

		// NG判定されなかったものはクリーン
		sql = "UPDATE keyword_search_logs SET ng=0 WHERE ng = -1";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			result = statement.executeUpdate();
			Log.d("Labeled " + String.valueOf(result) + " rows as NG.");
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}

		Log.d("CheckNgSearchLog batch end");
	}
}
