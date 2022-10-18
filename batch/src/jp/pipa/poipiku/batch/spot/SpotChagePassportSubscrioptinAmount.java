package jp.pipa.poipiku.batch.spot;

/*
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.time.LocalDate;

import okhttp3.*;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

public class SpotChagePassportSubscrioptinAmount extends Batch{
	static final String URL_SCHEME      = "https";

	public static void main(String[] args) {
		java.sql.Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		final String urlClearUserCacheF = URL_SCHEME + "://ai.poipiku.com/api/ClearUserCacheF.jsp?TOKEN=kkvjaw8per32qt3j28ycb4&ID=";
		final String urlChangeRegularlyAmountF = URL_SCHEME + "://ai.poipiku.com/api/ChangeRegularlyAmountF.jsp?TOKEN=08yg3qghpwj48q6742o97qwqvh&ID=%d&AMT=%d";
		OkHttpClient client = new OkHttpClient();

		LocalDate now = LocalDate.now();
		final int thisYear = now.getYear();
		final int thisMonth = now.getMonthValue();

		try {
			// CONNECT DB
			connection = dataSource.getConnection();


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

			// PassportPayment.java
			//     CreditCard(1),
			//     Ticket(2);
			// 今月はチケット払い
			// -> 金額を0円にする
			List<Integer> changeAmountUserIds = new ArrayList<>();
			statement = connection.prepareStatement(sql);
			statement.setInt(1, 2);
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
			statement.setInt(1, 1);
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
				}
			}
			changeAmountUserIds.clear();

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
*/