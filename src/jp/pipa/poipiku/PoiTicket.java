package jp.pipa.poipiku;

import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.*;


public final class PoiTicket {
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
	public int amount = -1;

	private static final int PRODUCT_ID = 2;

	private static final String sqlAdd =
			"INSERT INTO poi_tickets(user_id, amount)" +
			" VALUES (?, ?)" +
			" ON CONFLICT ON CONSTRAINT poi_tickets_pkey" +
			" DO UPDATE SET amount=poi_tickets.amount+?, updated_at=current_timestamp" +
			" RETURNING amount";

	private void init(int _userId) {
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		userId = _userId;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			sql = "SELECT amount FROM poi_tickets WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, _userId);
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				amount = resultSet.getInt("amount");
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
	}

	public PoiTicket(int userId) {
		init(userId);
	}

	public PoiTicket(CheckLogin checkLogin) {
		if(checkLogin == null || !checkLogin.m_bLogin) return;
		init(checkLogin.m_nUserId);
	}

	public boolean add(int addNum) {
		if (addNum<=0) return false;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			// insert or update poi_tickets
			sql = sqlAdd;
			Log.d(sql);
			statement = connection.prepareStatement(sqlAdd);
			statement.setInt(1, userId);
			statement.setInt (2, addNum);
			statement.setInt (3, addNum);
			resultSet = statement.executeQuery();
			resultSet.next();
			amount = resultSet.getInt(1);
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

	public boolean buy(int nPassportCourseId, int _amount, String strAgentToken, String strCardExpire,
					   String strCardSecurityCode, String strUserAgent) {
		if (_amount <= 0) {
			Log.d("_amount<=0");
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

			// 注文生成
			Order order = new Order();
			order.customerId = userId;
			order.sellerId = 2;
			order.paymentTotal = listPrice * _amount;
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
			orderDetail.quantity = _amount;
			if (orderDetail.insert() != 0 || orderDetail.id < 0) {
				throw new Exception("insert order_detail error");
			}

			final int nCreditCardId;
			boolean authorizeResult;
			CardSettlement cardSettlement = new CardSettlementEpsilon(userId);
			if (!isSkipSettlement) {
				cardSettlement.poipikuOrderId = order.id;
				cardSettlement.amount = order.paymentTotal;
				cardSettlement.agentToken = strAgentToken;
				cardSettlement.cardExpire = strCardExpire;
				cardSettlement.cardSecurityCode = strCardSecurityCode;
				cardSettlement.userAgent = strUserAgent;
				cardSettlement.billingCategory = CardSettlement.BillingCategory.OneTime;
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

			// insert or update poi_tickets
			sql = sqlAdd;
			Log.d(sql);
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt (2, _amount);
			statement.setInt (3, _amount);
			resultSet = statement.executeQuery();
			resultSet.next();
			amount = resultSet.getInt(1);

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

	public boolean use(){
		if (amount <= 0) {
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();
			sql = "UPDATE poi_tickets SET amount=poi_tickets.amount-1, updated_at=current_timestamp WHERE user_id=? RETURNING amount";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			resultSet = statement.executeQuery();
			resultSet.next();
			amount = resultSet.getInt(1);
			return true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
			try{if(connection!=null){connection.rollback();}}catch(SQLException ignore){}
			return false;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}
	}
}
