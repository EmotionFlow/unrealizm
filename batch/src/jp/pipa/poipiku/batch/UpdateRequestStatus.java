package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.util.SlackNotifier;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;
import java.util.Arrays;

public class UpdateRequestStatus extends Batch {
	public static void main(String args[]) {
		final String slackEndpointUrl = args[0];
		System.out.println(slackEndpointUrl);
		SlackNotifier slackNotifier = new SlackNotifier(slackEndpointUrl);

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql;
		List<Integer> requestIds = new ArrayList<>();
		try {
			// CONNECT DB
			connection = dataSource.getConnection();

			sql = "UPDATE requests SET status=-1 WHERE status=1 AND return_limit<CURRENT_DATE RETURNING id";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			while(resultSet.next()) {
				requestIds.add(resultSet.getInt("id"));
			}
			resultSet.close();
			statement.close();

			StringJoiner stringJoiner = new StringJoiner(",");
			Arrays.stream(requestIds.toArray()).forEach(i -> stringJoiner.add(String.valueOf(i)));
			System.out.println("返答期限切れによるキャンセル(有償無償問わず)");
			if (requestIds.isEmpty()) {
				System.out.println("なし");
			} else {
				System.out.println(stringJoiner.toString());
			}

			requestIds.clear();
			sql = "UPDATE requests SET status=-1 WHERE status=2 AND amount>0 AND delivery_limit<CURRENT_DATE RETURNING id";
			statement = connection.prepareStatement(sql);
			resultSet = statement.executeQuery();
			while(resultSet.next()) {
				requestIds.add(resultSet.getInt("id"));
			}
			resultSet.close();
			statement.close();

			Arrays.stream(requestIds.toArray()).forEach(i -> stringJoiner.add(String.valueOf(i)));
			System.out.println("納品期限切れによるキャンセル(有償のみ)");
			if (requestIds.isEmpty()) {
				System.out.println("なし");
				//slackNotifire.notify("リクエスト納品期限切れによるキャンセルはありませんでした。");
			} else {
				System.out.println(stringJoiner.toString());
				slackNotifier.notify("リクエスト納品期限切れによるキャンセルがあります。返金対応が必要です。\n" + stringJoiner.toString());

				final String RECORD =
						"request_id: %d, " +
						"order_id: %d\n" +
						"client: %d, " +
						"creator: %d\n" +
						"agency_order_id: %s\n" +
						"amount: %d, " +
						"commission: %d, " +
						"payment_total: %d";

				String msg;

				sql = String.format("select r.id request_id, o.id order_id, client_user_id, creator_user_id, " +
						" agency_order_id, amount, commission, payment_total" +
						" from requests r" +
						" inner join orders o on r.order_id=o.id where r.id in (%s) order by r.id", stringJoiner.toString());
				System.out.println(sql);
				statement = connection.prepareStatement(sql);
				resultSet = statement.executeQuery();
				while(resultSet.next()) {
					msg = String.format(RECORD,
							resultSet.getInt("request_id"),
							resultSet.getInt("order_id"),
							resultSet.getInt("client_user_id"),
							resultSet.getInt("creator_user_id"),
							resultSet.getString("agency_order_id"),
							resultSet.getInt("amount"),
							resultSet.getInt("commission"),
							resultSet.getInt("payment_total")
					);
					slackNotifier.notify(msg);
				}
				resultSet.close();
				statement.close();
			}
			connection.close();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if(resultSet!=null) resultSet.close();
				if(statement!=null) statement.close();
				if(connection!=null) connection.close();
			} catch (SQLException se) {
			}
		}
	}
}
