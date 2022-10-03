package jp.pipa.poipiku.batch.spot;

import jp.pipa.poipiku.PassportPayment;
import jp.pipa.poipiku.batch.Batch;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

public class SpotUpdatePassportMember extends Batch {
	static final boolean _DEBUG = false;
	static final String URL_SCHEME = (_DEBUG)?"http":"http";

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
			List<Integer> changeAmountUserIds = new ArrayList<>();

			// CONNECT DB
			connection = dataSource.getConnection();


			// 更新処理を経て、なお有効期限が先月末で切れているユーザー
			statement = connection.prepareStatement(sqlExpiredUsers);
			resultSet = statement.executeQuery();
			List<Integer> ignoredUserIds = new ArrayList<>();
			while(resultSet.next()) {
				ignoredUserIds.add(resultSet.getInt("user_id"));
			}
			resultSet.close();
			statement.close();


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
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string().replaceAll("\n", ""));
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
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string().replaceAll("\n", ""));
				} catch(NullPointerException ignored) {}
			}

			///////////////////////////////////////////////////////////////////////
			// 25日以降に解約された場合、イプシロン上では翌月解約扱いとなり、解約月の翌月に課金が発生してしまうため、課金額を0円に変更する。
			// 25日ピッタリにすると嫌な予感(ポイピクサーバとイプシロンサーバの時刻のずれによって不具合が生じるかも)がするので１分間余裕を持たせている
			LocalDate lastMonth = now.minusMonths(1);
			sql = String.format(
					"SELECT user_id FROM passport_subscriptions WHERE (cancel_datetime BETWEEN '%d-%02d-24 23:59:00' AND '%d-%02d-01')",
					lastMonth.getYear(),lastMonth.getMonthValue(),
					now.getYear(), now.getMonthValue()
			);
			System.out.println(sql);

			connection = dataSource.getConnection();
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();

			while (resultSet.next()) {
				changeAmountUserIds.add(resultSet.getInt(1));
			}
			resultSet.close();
			statement.close();
			connection.close();

			System.out.println(
					"25日以降に解約されたため、定期課金の金額を0円にするユーザー：" +
							changeAmountUserIds.stream().map(i -> i.toString()).collect(Collectors.joining(","))
			);

			// epsilon api
			for (Integer userId: changeAmountUserIds) {
				Request request = new Request.Builder().url(
						String.format(urlChangeRegularlyAmountF, userId, 0)
				).build();
				try (Response response = client.newCall(request).execute()) {
					System.out.println(userId.toString() + " " + Objects.requireNonNull(response.body()).string().replaceAll("\n", ""));
				} catch(NullPointerException ignored) {}
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
