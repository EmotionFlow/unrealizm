package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.Agent;
import jp.pipa.poipiku.util.Log;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

class EpsilonRegularlyPayment {
	public String userId;
	public int itemCode;
	public EpsilonRegularlyPayment(String _userId, int _itemCode) {
		userId = _userId;
		itemCode = _itemCode;
	}
}


/**
 * epsilon上で決済NGにより定期課金が解除されたポイパスの定期購入を解除し、
 * 購入に用いていたカードを無効化する。
 */
public class DeactivateCreditCards extends Batch {

	public static void main(String[] args) {
		Log.d("DeactivateCreditCards batch start");

		Path path = Paths.get(args[0]);
		Log.d("Read from " + path);

		List<EpsilonRegularlyPayment> regularlyPayments = new ArrayList<>();

		try {
			Files.lines(path, Charset.forName("MS932")).forEach(e -> {
				EpsilonRegularlyPayment payment = new EpsilonRegularlyPayment(
						e.split(",")[0].replace("\"",""),
						Integer.parseInt(e.split(",")[1].replace("\"",""))
				);
				regularlyPayments.add(payment);
			});
		} catch (IOException e) {
			e.printStackTrace();
		}


		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		final String sql =
				"SELECT c.user_id, c.id card_id, c.del_flg card_del_flg, c.invalid_flg card_invalid_flg, ps.cancel_datetime subscription_cancel_datetime" +
				" FROM orders o" +
				"   INNER JOIN passport_subscriptions ps ON o.id = ps.order_id" +
				"   INNER JOIN creditcards c ON o.creditcard_id = c.id" +
				" WHERE order_id = ?";

		try {
			int poipikuUserId;
			boolean isFound;
			int cardId;
			boolean cardDelFlg;
			boolean cardInvalidFlg;
			Timestamp subscriptionCancelDatetime;
			for (EpsilonRegularlyPayment payment : regularlyPayments) {
				Log.d(String.format("%s, %d", payment.userId, payment.itemCode));

				connection = dataSource.getConnection();
				statement = connection.prepareStatement(sql);
				statement.setInt(1, payment.itemCode);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					isFound = true;
					poipikuUserId = resultSet.getInt("user_id");
					cardId = resultSet.getInt("card_id");
					cardDelFlg = resultSet.getBoolean("card_del_flg");
					cardInvalidFlg = resultSet.getBoolean("card_invalid_flg");
					subscriptionCancelDatetime = resultSet.getTimestamp("subscription_cancel_datetime");
				} else {
					poipikuUserId = -1;
					isFound = false;
					cardId = -1;
					cardDelFlg = false;
					cardInvalidFlg = false;
					subscriptionCancelDatetime = null;
				}
				resultSet.close();
				statement.close();
				connection.close();

				if (!isFound) continue;

				// ポイパス継続中であったら利用停止する。
				if (subscriptionCancelDatetime == null) {
					PassportSubscription subscription = new PassportSubscription();
					subscription.userId = poipikuUserId;
					subscription.orderId = payment.itemCode;
					subscription.exists = true;
					if (!subscription.cancel()) {
						Log.d("ポイパス定期購入のキャンセルに失敗した");
					}
				}

				// ポイピクDB上でカードを無効化する
				Log.d(String.format("card: %d, %b, %b", cardId, cardDelFlg, cardInvalidFlg));
				if (!cardDelFlg && !cardInvalidFlg) {
					CreditCard creditCard = new CreditCard(poipikuUserId, Agent.EPSILON);
					creditCard.selectByUserIdAgentId();
					if (creditCard.invalidate()) {
						Log.d("クレジットカードを無効化した");
					} else {
						Log.d("クレジットカードの無効化に失敗した");
					}
				}
			}

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}

		Log.d("DeactivateCreditCards batch end");
	}
}
