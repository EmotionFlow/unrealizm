package jp.pipa.poipiku;

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

public final class RegisteredNotifier extends Notifier {
	public RegisteredNotifier() {
		CATEGORY = "register";
	}

	private static class NewUserFollower {
		User follower = new User();
		List<RecommendedUser> newUsers = new ArrayList<>();
	}

	public boolean welcomeFromTwitter(DataSource dataSource, int userId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean result = false;
		try {
			User user;
			String loginPassword = "";

			connection = dataSource.getConnection();
			sql = "SELECT user_id, nickname, email, lang_id, password FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				user = new User();
				user.id = resultSet.getInt(1);
				user.nickname = resultSet.getString(2);
				user.email = resultSet.getString(3);
				user.langId = resultSet.getInt(4);
				user.setLangLabel();
				loginPassword = resultSet.getString(5);
			} else {
				return false;
			}
			resultSet.close();
			statement.close();

			final int MAX_RECOMMENDED_USERS = 15;
			List<RecommendedUser> recommendedUsers = new ArrayList<>();
			// 登録ユーザーがフォローしているユーザーのうち、ポイピクにいる人を抽出
			sql = "SELECT user_id, nickname, profile" +
					" FROM users_0000" +
					" WHERE user_id IN (" +
					"    SELECT follow_user_id" +
					"    FROM twitter_friends" +
					"    WHERE user_id = ?" +
					"      AND follow_user_id IS NOT NULL" +
					");";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				RecommendedUser ru = new RecommendedUser();
				ru.userId = resultSet.getInt(1);
				ru.nickname = resultSet.getString(2);
				ru.profile = resultSet.getString(3);
				recommendedUsers.add(ru);
				if (recommendedUsers.size() >= MAX_RECOMMENDED_USERS) {
					break;
				}
			}

			if (recommendedUsers.size() < MAX_RECOMMENDED_USERS) {
				List<RecommendedUser> popularUsers = RecommendedUser.getPopularUsers(
						userId, connection, statement, resultSet);

				Iterator<RecommendedUser> it = popularUsers.iterator();
				while (recommendedUsers.size()<MAX_RECOMMENDED_USERS && it.hasNext()) {
					recommendedUsers.add(it.next());
				}
			}

			// メール本文生成
			String mailSubject = getSubject("welcome", user.langLabel);

			VelocityContext context = new VelocityContext();
			context.put("to_name", user.nickname);
			context.put("login_email", user.email);
			context.put("login_password", loginPassword);
			context.put("recommend_users", recommendedUsers);

			Template template = getBodyTemplate("welcome", user.langLabel);
			String mailBody = merge(template, context);

			// 配信
			notifyByEmail(user, mailSubject, mailBody);

			Log.d("sent welcome mail: " + user.email);

			result = true;
		} catch (SQLException e) {
			e.printStackTrace();
			Log.d(sql);
			result = false;
		} finally {
			if(resultSet!=null){try{resultSet.close();}catch(SQLException ignored){}};
			if(statement!=null){try{statement.close();}catch(SQLException ignored){}};
			if(connection!=null){try{connection.close();}catch(SQLException ignored){}};
		}

		return result;
	}

	// Twitterで自分をフォローしているユーザーに、自分がポイピクを始めたことをメールする。
	public boolean notifyToMyTwitterFollower(DataSource dataSource, int newUserIdFrom, int newUserIdTo) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean result = false;
		try {
			connection = dataSource.getConnection();
			sql = "WITH new_users AS (" +
					"SELECT flduserid, cast(twitter_user_id AS bigint) twitter_user_id_bigint FROM tbloauth WHERE" +
					"            flduserid >= ? AND flduserid <= ? AND del_flg = false" +
					")," +
					"followers AS (" +
					"    SELECT twitter_friends.user_id follower_user_id, new_users.flduserid new_user_id" +
					"    FROM twitter_friends" +
					"    INNER JOIN new_users ON twitter_friends.twitter_follow_user_id = new_users.twitter_user_id_bigint" +
					")" +
					" SELECT f.user_id f_user_id, f.nickname f_nickname, f.email f_email, f.lang_id f_lang_id," +
					"   n.user_id n_user_id, n.nickname n_nickname, n.profile n_profile" +
					" FROM followers fol" +
					"   LEFT JOIN users_0000 f ON f.user_id=fol.follower_user_id" +
					"   LEFT JOIN users_0000 n ON n.user_id=fol.new_user_id" +
					" WHERE f.email LIKE '%@%'" +
					"   AND f.user_id NOT IN (SELECT user_id FROM temp_emails_0000)" +
					"   AND f.email NOT IN (SELECT email FROM temp_emails_0000)" +
					" ORDER BY f_user_id, n_user_id;";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, newUserIdFrom);
			statement.setInt(2, newUserIdTo);
			resultSet = statement.executeQuery();

			List<NewUserFollower> newUserFollowerList = new ArrayList<>();
			{
				int uid = -1;
				NewUserFollower newUserFollower = null;
				while (resultSet.next()) {
					if (uid != resultSet.getInt("f_user_id")) {
						uid = resultSet.getInt("f_user_id");
						newUserFollower = new NewUserFollower();
						User follower = new User();
						follower.id = resultSet.getInt("f_user_id");
						follower.email = resultSet.getString("f_email");
						follower.nickname = resultSet.getString("f_nickname");
						follower.langId = resultSet.getInt("f_lang_id");
						follower.setLangLabel();
						newUserFollower.follower = follower;
						newUserFollowerList.add(newUserFollower);
					}
					RecommendedUser newUser = new RecommendedUser();
					newUser.userId = resultSet.getInt("n_user_id");
					newUser.nickname = resultSet.getString("n_nickname");
					newUser.profile = resultSet.getString("n_profile");
					if (newUserFollower != null) {
						newUserFollower.newUsers.add(newUser);
					}
				}
			}
			resultSet.close();
			statement.close();

			if (newUserFollowerList.isEmpty()) {
				Log.d("配信対象なし");
				return true;
			} else {
				Log.d(String.format("配信数 %d", newUserFollowerList.size()));
			}

			for (NewUserFollower newUserFollower : newUserFollowerList) {
				// メール本文生成
				String mailSubject = getSubject("twitter_follower", newUserFollower.follower.langLabel);

				VelocityContext context = new VelocityContext();
				context.put("to_name", newUserFollower.follower.nickname);
				context.put("recommend_users", newUserFollower.newUsers);

				Template template = getBodyTemplate("twitter_follower", newUserFollower.follower.langLabel);
				String mailBody = merge(template, context);

				// 配信
				notifyByEmail(newUserFollower.follower, mailSubject, mailBody);

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
