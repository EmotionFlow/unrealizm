package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.time.LocalDateTime;

import java.util.ArrayList;
import java.util.List;

public class CheckNgSearchLog extends Batch {
	public static void main(String[] args) {
		Log.d("CheckNgSearchLog batch start");
		LocalDateTime startAt = LocalDateTime.now();
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

		// NG未判定の検索ログに対してNG判定
		sql = "UPDATE keyword_search_logs SET ng=1 WHERE created_at < ? AND ng = -1 AND keywords &@~ '" + ngPattern + "'";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setTimestamp(1, Timestamp.valueOf(startAt));
			result = statement.executeUpdate();
			Log.d("Labeled " + String.valueOf(result) + " rows as NG.");
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}

		// バッチ起動前に作成されていて、NG判定されなかったものはクリーン
		sql = "UPDATE keyword_search_logs SET ng=0 WHERE created_at < ? AND ng = -1";
		try (
			Connection connection = dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
		) {
			statement.setTimestamp(1, Timestamp.valueOf(startAt));
			result = statement.executeUpdate();
			Log.d("Labeled " + String.valueOf(result) + " rows as NG.");
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}

		Log.d("CheckNgSearchLog batch end");
	}
}
