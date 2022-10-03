package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.Emoji;
import jp.pipa.poipiku.InfoList;
import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

class HasNotCheckedNotifier extends Notifier {
	private static final int MAX_SEND_USERS = 300;
	protected InfoList.InfoType infoType = InfoList.InfoType.Undefined;
	protected String vmTemplateStatus = "";
	protected int remindDay = 5;

	public HasNotCheckedNotifier() {
		vmTemplateCategory = "has_not_checked";
	}

	public boolean notifyReaction(DataSource dataSource) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean result = false;
		try {
			connection = dataSource.getConnection();
			sql = "SELECT i.user_id, u.email, u.nickname, u.lang_id" +
					" FROM info_lists i" +
					"         INNER JOIN users_0000 u ON i.user_id = u.user_id" +
					" WHERE i.info_type = ?" +
					"  AND i.had_read = FALSE" +
					"  AND i.info_date < (now() - INTERVAL '%d days')".formatted(remindDay) +
//					"  AND i.info_date < (timestamp '2022-01-06 00:00:00' - INTERVAL '14 days')" +
					"  AND u.email LIKE '%@%'" +
					"  AND u.hash_password NOT LIKE '%BAN'" +
					"  AND u.email NOT LIKE '%BAN'" +
					"  AND i.sent_unread_mail_at IS NULL" +
					"  AND send_email_mode = 1" +
					" GROUP BY i.user_id, u.email, u.nickname, u.lang_id" +
					" LIMIT ?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, infoType.getCode());
			statement.setInt(2, MAX_SEND_USERS);

//			Log.d(statement.toString());
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

			sql = "WITH a AS (" +
					"    SELECT content_id, SUM(badge_num) badge_sum" +
					"    FROM info_lists i" +
					"    WHERE i.info_type = ?" +
					"      AND i.had_read = FALSE" +
					"      AND i.user_id = ?" +
					"    GROUP BY content_id" +
					" )" +
					" SELECT COUNT(*) contents_total, SUM(badge_sum) badge_total" +
					" FROM a;";
			statement = connection.prepareStatement(sql);

			PreparedStatement updateStatement = connection.prepareStatement(
					"UPDATE info_lists SET sent_unread_mail_at=now() WHERE user_id=? AND info_type=?"
			);

			for (User targetUser : deliveryTargets) {
				// 未読通知のコンテンツ数とリアクション数の合計を求める
				statement.setInt(1, infoType.getCode());
				statement.setInt(2, targetUser.id);
				resultSet = statement.executeQuery();

				if (resultSet.next()) {
					int contentsTotal = resultSet.getInt(1);
					int reactionsTotal = resultSet.getInt(2);
					resultSet.close();

					// メール本文生成
					String mailSubject = getSubject(vmTemplateStatus, targetUser.langLabel);

					VelocityContext context = new VelocityContext();
					context.put("to_name", targetUser.nickname);
					context.put("contents_total", contentsTotal);
					context.put("reactions_total", reactionsTotal);

					Template template = getBodyTemplate(vmTemplateStatus, targetUser.langLabel);
					String mailBody = merge(template, context);

					// 配信
					notifyByEmail(targetUser, mailSubject, mailBody);

					//Log.d(String.format("send to: %s(%d)", targetUser.email, targetUser.id));

					// 配信済み設定
					updateStatement.setInt(1, targetUser.id);
					updateStatement.setInt(2, infoType.getCode());
					updateStatement.executeUpdate();

					// Amazon SES Maximum send rate is
					// 14 emails per second
					Thread.sleep(500);
				} else {
					resultSet.close();
				}
			}
			Log.d("配信数 " + deliveryTargets.size());
			result = true;
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

	class NotifyWaveInfo {
		NotifyWaveInfo(User _user, int _waveNum) {
			user = _user;
			waveNum = _waveNum;
		}
		User user;
		int waveNum;
	}

	public boolean notifyWave(DataSource dataSource) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		boolean result = false;
		try {
			connection = dataSource.getConnection();
			sql = "SELECT i.user_id, i.info_desc, u.email, u.nickname, u.lang_id" +
					" FROM info_lists i" +
					"         INNER JOIN users_0000 u ON i.user_id = u.user_id" +
					" WHERE i.info_type = ?" +
					"  AND i.had_read = FALSE" +
					"  AND i.info_date < (now() - INTERVAL '%d days')".formatted(remindDay) +
//					"  AND i.info_date < (timestamp '2022-01-06 00:00:00' - INTERVAL '14 days')" +
					"  AND u.email LIKE '%@%'" +
					"  AND u.hash_password NOT LIKE '%BAN'" +
					"  AND u.email NOT LIKE '%BAN'" +
					"  AND i.sent_unread_mail_at IS NULL" +
					"  AND send_email_mode = 1" +
					" LIMIT ?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, infoType.getCode());
			statement.setInt(2, MAX_SEND_USERS);

			resultSet = statement.executeQuery();
			List<NotifyWaveInfo> notifyInfoList = new LinkedList<>();
			while (resultSet.next()) {
				User u = new User();
				u.id = resultSet.getInt("user_id");
				u.email = resultSet.getString("email");
				u.nickname = resultSet.getString("nickname");
				u.langId = resultSet.getInt("lang_id");
				u.setLangLabel();
				notifyInfoList.add(new NotifyWaveInfo(u, Emoji.getLength(resultSet.getString("info_desc"))));
			}
			resultSet.close();
			statement.close();

			if (notifyInfoList.isEmpty()) {
				Log.d("配信対象なし");
				return true;
			}

			PreparedStatement updateStatement = connection.prepareStatement(
					"UPDATE info_lists SET sent_unread_mail_at=now() WHERE user_id=? AND info_type=?"
			);

			for (NotifyWaveInfo info : notifyInfoList) {
				final User targetUser = info.user;
				final int wavesTotal = info.waveNum;

				// メール本文生成
				String mailSubject = getSubject(vmTemplateStatus, targetUser.langLabel);

				VelocityContext context = new VelocityContext();
				context.put("to_name", targetUser.nickname);
				context.put("waves_total", wavesTotal);

				Template template = getBodyTemplate(vmTemplateStatus, targetUser.langLabel);
				String mailBody = merge(template, context);

				// 配信
				notifyByEmail(targetUser, mailSubject, mailBody);

				//Log.d(String.format("send to: %s(%d)", targetUser.email, targetUser.id));

				// 配信済み設定
				updateStatement.setInt(1, targetUser.id);
				updateStatement.setInt(2, infoType.getCode());
				updateStatement.executeUpdate();

				// Amazon SES Maximum send rate is
				// 14 emails per second
				Thread.sleep(500);
			}
			Log.d("配信数 " + notifyInfoList.size());
			result = true;
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
