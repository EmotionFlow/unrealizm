package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

class TblOauthRecord {
	public int id;
	public int userId;
	public String twitterUserId;
	public String twitterScreenName;
	public String twitterAccessToken;
	public String twitterSecretToken;
	public String tweetId;

	TblOauthRecord(int _id, int _userId, String _twitterUserId, String _twitterScreenName, String _twitterAccessToken, String _twitterSecretToken, String _tweeetId) {
		id = _id;
		userId = _userId;
		twitterUserId = _twitterUserId;
		twitterScreenName = _twitterScreenName;
		twitterAccessToken = _twitterAccessToken;
		twitterSecretToken = _twitterSecretToken;
		tweetId = _tweeetId;
	}
}

public class SpotUpdateTbloauth extends Batch {
	public static void main(String[] args) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		List<Integer> uidList = new ArrayList<>();

		try {
			connection = dataSource.getConnection();

			sql = "WITH a AS(\n" +
					"    SELECT flduserid,COUNT(*) cnt FROM tbloauth\n" +
					"    WHERE del_flg=FALSE\n" +
					"    GROUP BY flduserid\n" +
					"    HAVING COUNT(*) > 1\n" +
					"    ORDER BY cnt DESC\n" +
					")\n" +
					"SELECT a.flduserid\n" +
					"FROM tbloauth t\n" +
					"         INNER JOIN a ON a.flduserid=t.flduserid\n" +
					"GROUP BY a.flduserid\n" +
					"ORDER BY flduserid";

			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				uidList.add(resultSet.getInt(1));
			}
			resultSet.close();
			statement.close();


			sql = "SELECT id, flduserid, twitter_user_id, twitter_screen_name, fldaccesstoken, fldsecrettoken, tweet_id" +
					" FROM tbloauth WHERE flduserid=? AND del_flg=FALSE ORDER BY id DESC";
			for (int uid : uidList) {
				statement = connection.prepareStatement(sql);
				statement.setInt(1, uid);
				resultSet = statement.executeQuery();

				List<TblOauthRecord> records = new ArrayList<>();
				while (resultSet.next()) {
					TblOauthRecord r = new TblOauthRecord(
							resultSet.getInt(1),
							resultSet.getInt(2),
							resultSet.getString(3),
							resultSet.getString(4),
							resultSet.getString(5),
							resultSet.getString(6),
							resultSet.getString(7)
					);
					records.add(r);
				}
				resultSet.close();
				statement.close();

				for (TblOauthRecord r : records) {
					String twIdFrmAccessToken = r.twitterAccessToken.split("-")[0];
					if (!twIdFrmAccessToken.equals(r.twitterUserId)) {
						statement = connection.prepareStatement("UPDATE tbloauth SET twitter_user_id=? WHERE id=?");
						statement.setString(1, twIdFrmAccessToken);
						statement.setInt(2, r.id);

						Log.d(String.format("update twitter_user_id %d, now: %s, now: %s, new: %s", r.id, r.twitterUserId, r.twitterAccessToken, twIdFrmAccessToken));
						statement.executeUpdate();
						r.twitterUserId = twIdFrmAccessToken;
						CTweet.updateTwitterCash(uid);
					}
				}

				TblOauthRecord head = records.get(0);
				for (int i = 1; i < records.size(); i++) {
					TblOauthRecord r = records.get(i);
					if (head.twitterUserId.equals(r.twitterUserId) &&
							head.twitterScreenName.equals(r.twitterScreenName) &&
							head.twitterAccessToken.equals(r.twitterAccessToken) &&
							head.twitterSecretToken.equals(r.twitterSecretToken)
					) {
						if (!(r.tweetId == null) && head.tweetId == null) {
							statement = connection.prepareStatement("UPDATE tbloauth SET tweet_id=? WHERE id=?");
							statement.setString(1, r.tweetId);
							statement.setInt(2, head.id);
							Log.d(String.format("update tweet_id %d, %d, %s", r.userId, r.id, r.tweetId));
							statement.executeUpdate();
						}

						statement = connection.prepareStatement("DELETE FROM tbloauth WHERE id=?");
						statement.setInt(1, r.id);
						Log.d(String.format("del %d", r.id));
						statement.executeUpdate();
					}
				}
				Thread.sleep(100);
			}
		} catch (SQLException | InterruptedException e) {
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
