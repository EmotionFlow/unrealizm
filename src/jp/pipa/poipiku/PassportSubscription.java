package jp.pipa.poipiku;

import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;


public final class PassportSubscription {
	public boolean isSkipSettlement = false;
	public enum ErrorKind implements CodeEnum<ErrorKind> {
		None(0),
		DoRetry(-10),	    // リトライして欲しい。それでもダメなら問い合わせて欲しい。
		NeedInquiry(-20),	// 決済されているか不明なエラー。運営に問い合わせて欲しい。
		CardAuth(-30),    // カード認証周りのエラー。
		Unknown(-99);     // 不明。通常ありえない。

		private final int code;
		private ErrorKind(int code) {
			this.code = code;
		}

		@Override
		public int getCode() {
			return code;
		}
	}
	public ErrorKind errorKind = ErrorKind.Unknown;

	public boolean exists = false;
	public int userId = -1;
	public int orderId = -1;
	public Timestamp subscriptionAt = null;
	public Timestamp cancelAt = null;
	public int passportCourseId = -1;

	public enum Status {
		Undefined,
		UnderContraction,
		Cancelling,
		UnContracted;
	}
	
	private static final int PRODUCT_ID = 1;

	public Status getStatus(){
		Status status;
		if (!exists) {
			status = Status.UnContracted;
		} else {
			if (cancelAt == null) {
				status = Status.UnderContraction;
			} else {
				LocalDate now = LocalDate.now();
				LocalDateTime cancelDt = cancelAt.toLocalDateTime();
				if (now.getYear() == cancelDt.getYear() && now.getMonthValue() == cancelDt.getMonthValue()) {
					status = Status.Cancelling;
				} else {
					status = Status.UnContracted;
				}
			}
 		}
		return status;
	}

	public PassportSubscription(CheckLogin checkLogin) {
		if(checkLogin == null || !checkLogin.m_bLogin) return;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "SELECT * FROM passport_subscriptions WHERE user_id=? ORDER BY subscription_datetime DESC LIMIT 1";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				orderId = resultSet.getInt("order_id");
				subscriptionAt = resultSet.getTimestamp("subscription_datetime");
				cancelAt = resultSet.getTimestamp("cancel_datetime");
				exists = true;
			}

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}

		userId = checkLogin.m_nUserId;
		passportCourseId = checkLogin.m_nPassportId;
		errorKind = ErrorKind.None;
	}

	public boolean buy(int nPassportCourseId, String strAgentToken, String strCardExpire,
					   String strCardSecurityCode, String strUserAgent) {
		if(userId < 1){
			Log.d("userId < 1");
			errorKind = ErrorKind.DoRetry;
			return false;
		}
		if(passportCourseId == nPassportCourseId){
			Log.d("m_nPassportId==nPassportId");
			errorKind = ErrorKind.DoRetry;
			return false;
		}
		if(nPassportCourseId <= 0){
			Log.d("nPassportId<=0");
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			String productName = null;
			int listPrice = -1;
			sql = "SELECT name, list_price FROM products WHERE id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, PRODUCT_ID);
			resultSet = statement.executeQuery();

			if(resultSet.next()){
				productName = resultSet.getString(1);
				listPrice = resultSet.getInt(2);
			}else{
				Log.d("不正なproduct_id");
				errorKind = ErrorKind.DoRetry;
				return false;
			}
			resultSet.close();
			statement.close();

			sql = "SELECT 1 FROM passport_subscriptions WHERE user_id=? AND cancel_datetime IS NULL LIMIT 1";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			if(resultSet.next()){
				Log.d("二重に契約しようとした:" + userId);
				errorKind = ErrorKind.DoRetry;
				return false;
			}

			resultSet.close();
			statement.close();

			// 注文生成
			Order order = new Order();
			order.customerId = userId;
			order.sellerId = 2;
			order.paymentTotal = listPrice;
			order.cheerPointStatus = Order.CheerPointStatus.NotApplicable;
			if (order.insert() != 0 || order.id < 0) {
				throw new Exception("insert order error");
			}

			OrderDetail orderDetail = new OrderDetail();
			orderDetail.orderId = order.id;
			orderDetail.productId = PRODUCT_ID;
			orderDetail.productCategory = OrderDetail.ProductCategory.Passport;
			orderDetail.productName = productName;
			orderDetail.listPrice = listPrice;
			orderDetail.amountPaid = listPrice;
			orderDetail.quantity = 1;
			if (orderDetail.insert() != 0 || orderDetail.id < 0) {
				throw new Exception("insert order_detail error");
			}

			final int nCreditCardId;
			boolean authorizeResult;
			CardSettlement cardSettlement = new CardSettlementEpsilon(userId);
			if (!isSkipSettlement) {
				cardSettlement.poipikuOrderId = order.id;
				cardSettlement.amount = listPrice;
				cardSettlement.agentToken = strAgentToken;
				cardSettlement.cardExpire = strCardExpire;
				cardSettlement.cardSecurityCode = strCardSecurityCode;
				cardSettlement.userAgent = strUserAgent;
				cardSettlement.billingCategory = CardSettlement.BillingCategory.Monthly;
				cardSettlement.itemName = CardSettlement.ItemName.Poipass;
				authorizeResult = cardSettlement.authorize();
				if (!authorizeResult) {
					Log.d("cardSettlement.authorize() failed.");
					if (cardSettlement.errorKind == CardSettlement.ErrorKind.CardAuth) {
						errorKind = ErrorKind.CardAuth;
					} else if(cardSettlement.errorKind == CardSettlement.ErrorKind.NeedInquiry) {
						errorKind = ErrorKind.NeedInquiry;
					} else {
						errorKind = ErrorKind.DoRetry;
					}
					return false;
				}
				nCreditCardId = cardSettlement.creditcardIdToPay;
			} else {
				nCreditCardId = -1;
				authorizeResult = true;
			}

			//// begin transaction
			connection.setAutoCommit(false);

			// insert into passport_subscriptions
			sql = "INSERT INTO passport_subscriptions(user_id, subscription_datetime, cancel_datetime, order_id)" +
					" VALUES (?, current_timestamp, null, ?)";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt (2, order.id);
			statement.executeUpdate();


			// update orders
			sql = "UPDATE orders SET creditcard_id=?, status=?, agency_order_id=?, updated_at=now() WHERE id=?";
			statement = connection.prepareStatement(sql);
			int idx=1;
			statement.setInt(idx++, nCreditCardId);
			statement.setInt(idx++,    authorizeResult ? Order.Status.SettlementOk.getCode() : Order.Status.SettlementError.getCode());
			statement.setString(idx++, authorizeResult ? cardSettlement.getAgentOrderId() : null);
			statement.setInt(idx++, order.id);
			statement.executeUpdate();

			connection.commit();
			statement.close();statement=null;
			connection.setAutoCommit(true);

			//// end transaction

			errorKind = ErrorKind.None;

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
			try{if(connection!=null){connection.rollback();}}catch(SQLException ignore){}
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception ignored){;}
		}
		
		return true;
	}

	public boolean cancel() {
		if(cancelAt != null){
			Log.d("解約済み");
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			// 定期課金キャンセル
			CardSettlement cardSettlement = new CardSettlementEpsilon(userId);
			boolean authorizeResult = cardSettlement.cancelSubscription(orderId);
			if (!authorizeResult) {
				Log.d("cardSettlement.authorize() failed.");
				errorKind = ErrorKind.DoRetry;
				return false;
			}

			// update passport_subscriptions
			cConn = DatabaseUtil.dataSource.getConnection();
			strSql = "UPDATE passport_subscriptions SET cancel_datetime=current_timestamp WHERE user_id=? AND order_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, userId);
			cState.setInt(2, orderId);
			cState.executeUpdate();
			cState.close();cState=null;
			cConn.close();cConn=null;

			errorKind = ErrorKind.None;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
			return false;
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception ignored){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception ignored){;}
		}

		return true;
	}
}
