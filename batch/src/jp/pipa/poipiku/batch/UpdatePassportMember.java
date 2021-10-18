package jp.pipa.poipiku.batch;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.time.LocalDate;
import java.time.LocalDateTime;

import jp.pipa.poipiku.PassportPayment;
import okhttp3.*;

public class UpdatePassportMember extends Batch{
	static final boolean _DEBUG = false;
	static final String URL_SCHEME = (_DEBUG)?"http":"https";

	public static void main(String[] args) {
		java.sql.Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		final String urlClearUserCacheF = URL_SCHEME + "://poipiku.com/api/ClearUserCacheF.jsp?TOKEN=kkvjaw8per32qt3j28ycb4&ID=";
		final String urlChangeRegularlyAmountF = URL_SCHEME + "://poipiku.com/api/ChangeRegularlyAmountF.jsp?TOKEN=08yg3qghpwj48q6742o97qwqvh&ID=%d&AMT=%d";
		OkHttpClient client = new OkHttpClient();

		LocalDate now = LocalDate.now();
		final int thisYear = now.getYear();
		final int thisMonth = now.getMonthValue();

		LocalDateTime endOfMonth = LocalDateTime.now()
				.plusMonths(1)
				.withDayOfMonth(1)
				.withHour(23)
				.withMinute(59)
				.withSecond(59)
				.withNano(0)
				.minusDays(1);

		final String sqlExpiredUsers = "SELECT user_id FROM passports WHERE (status = 1 OR status = 2) AND expired_at < DATE_TRUNC('month', NOW())";

		try {
			// CONNECT DB
			connection = dataSource.getConnection();

			////////////////////////////////////
			// 毎月１日の0:00~本スクリプト実行時に新規にポイパス登録されたユーザは、
			// 有効期限が今月末になっているので、処理から除外している。

			// 現在有効で期限が先月末のユーザーのうち、チケットを持っていたら、一枚使う。
			List<Integer> byTicketUserIds = new ArrayList<>();
			sql = "UPDATE poi_tickets SET amount = poi_tickets.amount - 1, updated_at=current_timestamp" +
					" WHERE poi_tickets.amount > 0 AND user_id IN (" + sqlExpiredUsers + ")" +
					" RETURNING user_id";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			while(resultSet.next()){
				byTicketUserIds.add(resultSet.getInt("user_id"));
			}
			System.out.println(
					"チケットを使ったユーザー: " +
							byTicketUserIds.stream().map(i -> i.toString()).collect(Collectors.joining(","))
			);
			resultSet.close();
			statement.close();

			if (byTicketUserIds.size() > 0) {
				// チケットを使ったユーザーは、今月チケット払い。
				sql = "INSERT INTO passport_payments(user_id, year, month, by) VALUES ";
				String values = byTicketUserIds.stream()
						.map(i -> (String.format("(%d,%d,%d,2)", i, thisYear, thisMonth)))
						.collect(Collectors.joining(","));
				sql += values;
				statement = connection.prepareStatement(sql);
				System.out.println(sql);
				statement.executeUpdate();
				statement.close();
			}

			// 定期購入中のユーザーで、チケットが使われなかったユーザーは、カード払い。
			// 今月に入って新規に登録されたユーザーは対象外（新規登録時に処理済み）
			List<Integer> byCreditCardUserIds = new ArrayList<>();
			sql = "SELECT user_id FROM passport_subscriptions" +
					" WHERE subscription_datetime < DATE_TRUNC('month', NOW()) AND (cancel_datetime IS NULL OR cancel_datetime >= DATE_TRUNC('month', NOW())) AND order_id>0";
			if (byTicketUserIds.size() > 0) {
				sql += " AND user_id NOT IN " +
						(String)(byTicketUserIds.stream().map(i -> i.toString()).collect(Collectors.joining(",", "(", ")")));
			}
			statement = connection.prepareStatement(sql);
			System.out.println(sql);
			resultSet = statement.executeQuery();
			while(resultSet.next()){
				byCreditCardUserIds.add(resultSet.getInt("user_id"));
			}
			resultSet.close();
			statement.close();

			// カード払い登録
			if (byCreditCardUserIds.size() > 0) {
				sql = "INSERT INTO passport_payments(user_id, year, month, by) VALUES ";
				String values = byCreditCardUserIds.stream()
						.map(i -> (String.format("(%d,%d,%d,1)", i, thisYear, thisMonth)))
						.collect(Collectors.joining(","));
				sql += values;
				statement = connection.prepareStatement(sql);
				System.out.println(sql);
				statement.executeUpdate();
				statement.close();
			} else {
				System.out.println("カード払い対象者なし");
			}

			if (byTicketUserIds.size() > 0 || byCreditCardUserIds.size() > 0) {
				// パスポート期限を今月末にする
				List<Integer> list = new ArrayList<>();
				list.addAll(byTicketUserIds);
				list.addAll(byCreditCardUserIds);
				sql = "UPDATE passports SET expired_at=?, updated_at=current_timestamp WHERE user_id IN " +
						(String)list.stream()
								.map(i -> i.toString())
								.collect(Collectors.joining(",", "(", ")"));
				statement = connection.prepareStatement(sql);
				System.out.println(sql);
				statement.setTimestamp(1, Timestamp.valueOf(endOfMonth));
				statement.executeUpdate();
				statement.close();
			}


			// 更新処理を経て、なお有効期限が先月末で切れているユーザー
			statement = connection.prepareStatement(sqlExpiredUsers);
			resultSet = statement.executeQuery();
			List<Integer> ignoredUserIds = new ArrayList<>();
			while(resultSet.next()) {
				ignoredUserIds.add(resultSet.getInt("user_id"));
			}
			resultSet.close();
			statement.close();

			// ポイパスを無効にする
			if (ignoredUserIds.size() > 0) {
				String inIds = ignoredUserIds.stream()
						.map(i -> ((Integer) i).toString())
						.collect(Collectors.joining(",", "(", ")"));

				sql = "UPDATE passports SET status=3, updated_at=current_timestamp WHERE user_id IN " + inIds;
				statement = connection.prepareStatement(sql);
				System.out.println(sql);
				statement.executeUpdate();
				statement.close();

				sql = "UPDATE users_0000 SET passport_id=0 WHERE user_id IN " + inIds;
				statement = connection.prepareStatement(sql);
				System.out.println(sql);
				statement.executeUpdate();
				statement.close();
			} else {
				System.out.println("ポイパスを無効にする対象者なし");
			}

			// 定期購入中ユーザーの課金額を更新する
			final String sqlPaymentsThisMonth = String.format(
					"SELECT * FROM passport_payments WHERE year=%d AND month=%d",
					thisYear, thisMonth);

			final String sqlActiveSubscriptionUsers =
					"SELECT user_id FROM passport_subscriptions" +
							" WHERE (cancel_datetime IS NULL OR cancel_datetime >= DATE_TRUNC('month', NOW())) AND order_id>0";

			final String sqlSubTables = String.format(
					"WITH payments_this_month AS (%s), active_subscription_users AS (%s)",
					sqlPaymentsThisMonth, sqlActiveSubscriptionUsers);

			sql = sqlSubTables +
					" SELECT asu.user_id FROM active_subscription_users asu" +
					" INNER JOIN payments_this_month ptm ON asu.user_id=ptm.user_id" +
					" WHERE ptm.by=?";

			System.out.println(sql);

			// 今月はチケット払い
			// -> 金額を0円にする
			List<Integer> changeAmountUserIds = new ArrayList<>();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, PassportPayment.By.Ticket.getCode());
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				changeAmountUserIds.add(resultSet.getInt(1));
			}
			resultSet.close();
			statement.close();

			// 次の処理に時間がかかるので、一度接続を閉じる
			connection.close();

			System.out.println(
					"定期課金の金額を0円にするユーザー：" +
							changeAmountUserIds.stream().map(i -> i.toString()).collect(Collectors.joining(","))
			);

			// epsilon api
			for (Integer userId: changeAmountUserIds) {
				Request request = new Request.Builder().url(
						String.format(urlChangeRegularlyAmountF, userId, 0)
				).build();
				try (Response response = client.newCall(request).execute()) {
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string());
				}
			}
			changeAmountUserIds.clear();


			// 今月はカード払い
			// -> 金額を300円にする
			connection = dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, PassportPayment.By.CreditCard.getCode());
			resultSet = statement.executeQuery();

			while (resultSet.next()) {
				changeAmountUserIds.add(resultSet.getInt(1));
			}
			resultSet.close();
			statement.close();
			connection.close();

			System.out.println(
					"定期課金の金額を300円にするユーザー：" +
							changeAmountUserIds.stream().map(i -> i.toString()).collect(Collectors.joining(","))
			);

			// epsilon api
			for (Integer userId: changeAmountUserIds) {
				Request request = new Request.Builder().url(
						String.format(urlChangeRegularlyAmountF, userId, 300)
				).build();
				try (Response response = client.newCall(request).execute()) {
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string());
				} catch(NullPointerException ignored) {}
			}
			changeAmountUserIds.clear();

			// clear user cache
			for (Integer userId: ignoredUserIds){
				Request request = new Request.Builder().url(urlClearUserCacheF + userId.toString()).build();
				try (Response response = client.newCall(request).execute()) {
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string());
				} catch(NullPointerException ignored) {}
			}
		} catch (Exception e) {
			System.out.println(sql);
			e.printStackTrace();
		} finally {
			try {
				if(resultSet!=null) resultSet.close();
				if(statement!=null) statement.close();
				if(connection!=null) {connection.setAutoCommit(true); connection.close();}
			} catch (SQLException ignored) {
			}
		}
	}
}
