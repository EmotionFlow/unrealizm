package jp.pipa.poipiku.notify;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RecommendedUser {
	public int userId = -1;
	public String nickname = "";
	public String profile = "";
	public Integer requestCreatorStatus = null;

	public String getNickname() {
		return nickname;
	}

	public int getUserId() {
		return userId;
	}

	public String getProfile() {
		if (profile.isEmpty()) return "";
		String[] lines = profile.split("\n");
		String line = lines[0];
		if (lines.length > 1) {
			line += " " + lines[1];
		}
		return line;
	}

	public int getRequestCreatorStatus() {
		return requestCreatorStatus;
	}

	static public List<RecommendedUser> getPopularUsers (
			int userId, Connection connection, PreparedStatement statement, ResultSet resultSet) throws SQLException {
		List<RecommendedUser> popularUsers = new ArrayList<>();
		String sql = "WITH populars AS (" +
				"    SELECT user_id" +
				"    FROM rank_contents_total" +
				"    ORDER BY add_date DESC" +
				"    LIMIT 100" +
				")" +
				"   , sorted_users AS (" +
				"    SELECT c.user_id" +
				"    FROM contents_0000 c" +
				"    WHERE c.user_id IN (SELECT * FROM populars)" +
				"      AND publish_id = 0" +
				"    GROUP BY c.user_id" +
				"    ORDER BY COUNT(*) DESC" +
				")" +
				"SELECT u.user_id, u.nickname, u.profile, rc.status" +
				" FROM users_0000 u" +
				"         LEFT JOIN request_creators rc ON u.user_id = rc.user_id" +
				" WHERE u.user_id IN (SELECT * FROM sorted_users)" +
				" AND u.user_id NOT IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?)";
		statement = connection.prepareStatement(sql);
		statement.setInt(1, userId);
		resultSet = statement.executeQuery();
		while (resultSet.next()) {
			RecommendedUser user = new RecommendedUser();
			user.userId = resultSet.getInt("user_id");
			user.nickname = resultSet.getString("nickname");
			user.profile = resultSet.getString("profile");
			user.requestCreatorStatus = resultSet.getInt("status");
			popularUsers.add(user);
		}
		resultSet.close();
		statement.close();

		return popularUsers;
	}
}
