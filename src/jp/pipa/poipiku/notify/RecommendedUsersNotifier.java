package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public final class RecommendedUsersNotifier extends Notifier {
	private static final int MAX_RECOMMENDED_USERS = 10;

	public RecommendedUsersNotifier() {
		vmTemplateCategory = "recommended";
		infoType = Common.NOTIFICATION_TYPE_REQUEST_STARTED;
	}

	public boolean notifyToLongSilenceUser(DataSource dataSource) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean result = false;
		try {
			connection = dataSource.getConnection();
			// １ヶ月以上アクセスしていないユーザーのうち、４週間以上DMしていないユーザー
			// かつ、DM許可しているユーザー。今までDMしていない人を優先。
			sql = "SELECT user_id, email, nickname, lang_id, last_login_date" +
					" FROM users_0000" +
					" WHERE last_login_date < CURRENT_TIMESTAMP - INTERVAL '1 month'" +
					"  AND (last_dm_delivery_date IS NULL OR last_dm_delivery_date < CURRENT_TIMESTAMP - INTERVAL '4 week')" +
					"  AND email IS NOT NULL" +
					"  AND email LIKE '%@%'" +
					"  AND send_email_mode = 1" +
					"  AND user_id NOT IN (SELECT user_id FROM temp_emails_0000)" +
					" ORDER BY last_dm_delivery_date DESC NULLS FIRST, last_login_date DESC LIMIT 1000";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			List<User> deliveryTargets = new ArrayList<>();
			while (resultSet.next()) {
				User u = new User();
				u.id = resultSet.getInt("user_id");
				u.email = resultSet.getString("email");
				u.nickname = resultSet.getString("nickname");
				u.langId = resultSet.getInt("lang_id");
				u.setLangLabel();
				deliveryTargets.add(u);
			}
			resultSet.close();
			statement.close();

			if (deliveryTargets.isEmpty()) {
				Log.d("配信対象なし");
				return true;
			}

			for (User targetUser : deliveryTargets) {
				// Twitterでフォローしているが、こそフォロしていないユーザー
				// Twitterでフォローしているが、こそフォロしていないユーザーのうち、リクエスト募集しているユーザー
				sql = "WITH" +
						" poipiku_followers AS (" +
						"    SELECT follow_user_id" +
						"    FROM follows_0000" +
						"    WHERE user_id = ?" +
						")," +
						" not_following_users AS (" +
						"    SELECT follow_user_id" +
						"    FROM twitter_friends" +
						"    WHERE user_id = ?" +
						"      AND follow_user_id IS NOT NULL" +
						"      AND follow_user_id NOT IN (SELECT * FROM poipiku_followers)" +
						")" +
						" SELECT u.user_id, nickname, u.profile, rc.status" +
						" FROM users_0000 u" +
						"         INNER JOIN not_following_users ON u.user_id = not_following_users.follow_user_id" +
						"         INNER JOIN (SELECT user_id, COUNT(*) cnt FROM contents_0000 GROUP BY user_id) content_cnt" +
						"                    ON u.user_id = content_cnt.user_id" +
						"         LEFT JOIN request_creators rc ON u.user_id = rc.user_id" +
						" ORDER BY content_cnt.cnt DESC;";

				statement = connection.prepareStatement(sql);
				statement.setInt(1, targetUser.id);
				statement.setInt(2, targetUser.id);
				resultSet = statement.executeQuery();
				List<RecommendedUser> recommendedUsers = new ArrayList<>();
				while (resultSet.next()) {
					RecommendedUser user = new RecommendedUser();
					user.userId = resultSet.getInt("user_id");
					user.nickname = resultSet.getString("nickname");
					user.profile = resultSet.getString("profile");
					user.requestCreatorStatus = resultSet.getInt("status");
					recommendedUsers.add(user);
					if (recommendedUsers.size()>=MAX_RECOMMENDED_USERS) {
						break;
					}
				}
				resultSet.close();
				statement.close();

				if (recommendedUsers.size()<MAX_RECOMMENDED_USERS) {
					List<RecommendedUser> popularUsers = RecommendedUser.getPopularUsers(
							targetUser.id, connection, statement, resultSet);

					Iterator<RecommendedUser> it = popularUsers.iterator();
					while (recommendedUsers.size()<MAX_RECOMMENDED_USERS && it.hasNext()) {
						recommendedUsers.add(it.next());
					}
				}

				// メール本文生成
				String mailSubject = getSubject("users", targetUser.langLabel);

				VelocityContext context = new VelocityContext();
				context.put("to_name", targetUser.nickname);
				context.put("recommend_users", recommendedUsers);

				Template template = getBodyTemplate("users", targetUser.langLabel);
				String mailBody = merge(template, context);

				// 配信
				notifyByEmail(targetUser, mailSubject, mailBody);

				// 配信日時更新
				sql = "UPDATE users_0000 SET last_dm_delivery_date=current_timestamp WHERE user_id=?";
				statement = connection.prepareStatement(sql);
				statement.setInt(1, targetUser.id);
				statement.executeUpdate();
				statement.close();

				// Amazon SES Maximum send rate is
				// 14 emails per second
				Thread.sleep(100);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
		} catch (InterruptedException e) {
			e.printStackTrace();
		} finally {
			if(resultSet!=null){try{resultSet.close();}catch(SQLException ignored){}};
			if(statement!=null){try{statement.close();}catch(SQLException ignored){}};
			if(connection!=null){try{connection.close();}catch(SQLException ignored){}};
		}

		return result;
	}
}
