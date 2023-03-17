package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.batch.Batch;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;


public class SpotUpdateTbloauth2 extends Batch {
	static class DeleteTarget {
		int userId;
		String twitterUserId;
		String accessToken;
		String twitterScreenName;
	}

	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<DeleteTarget> deleteTargets = new ArrayList<>();

		try {
			connection = dataSource.getConnection();

			sql = "select flduserid, twitter_user_id, fldaccesstoken, twitter_screen_name, count(flduserid) from tbloauth\n" +
					"where del_flg=false\n" +
					"group by flduserid, twitter_user_id, fldaccesstoken, twitter_screen_name\n" +
					"having count(*)>1";

			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				DeleteTarget deleteTarget = new DeleteTarget();
				deleteTarget.userId = resultSet.getInt(1);
				deleteTarget.twitterUserId = resultSet.getString(2);
				deleteTarget.accessToken = resultSet.getString(3);
				deleteTarget.twitterScreenName = resultSet.getString(4);
				deleteTargets.add(deleteTarget);
			}
			resultSet.close();
			statement.close();

			List<Integer> ids = new ArrayList<>();
			sql = "SELECT id FROM tbloauth WHERE flduserid=? AND twitter_user_id=? AND fldaccesstoken=? AND twitter_screen_name=? AND del_flg=false ORDER BY id DESC";
			statement = connection.prepareStatement(sql);
			for (DeleteTarget tgt: deleteTargets) {
				statement.setInt(1, tgt.userId);
				statement.setString(2, tgt.twitterUserId);
				statement.setString(3, tgt.accessToken);
				statement.setString(4, tgt.twitterScreenName);
				resultSet = statement.executeQuery();
				resultSet.next();
				while (resultSet.next()) {
					ids.add(resultSet.getInt(1));
				}
				resultSet.close();resultSet=null;
			}
			statement.close();statement=null;


			sql = "DELETE FROM tbloauth WHERE id IN "
					+ ids.stream().map(Object::toString).collect(Collectors.joining(",", "(", ")"));

			statement = connection.prepareStatement(sql);
			statement.executeUpdate();

		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
		} finally {
			if (resultSet != null) {
				try {
					resultSet.close();
				} catch (SQLException ignored) {
				}
			}
			if (statement != null) {
				try {
					statement.close();
				} catch (SQLException ignored) {
				}
			}
			if (connection != null) {
				try {
					connection.close();
				} catch (SQLException ignored) {
				}
			}
		}
	}
}
