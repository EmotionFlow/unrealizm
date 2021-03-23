package jp.pipa.poipiku;

import java.sql.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.Log;


public class Passport {
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

	public int m_nUserId = -1;
	public int m_nPassportId = -1;
	public int m_nOrderId = -1;
	public Timestamp m_tsSubscription = null;
	public Timestamp m_tsRelease = null;

	public Boolean m_bCancellationHistory = null;
	public enum Status {
		Undef,// 非ログインユーザーなど
		NotMember,  // パスポートなし
		Billing,	// 購入中、支払期間中、会員有効
		Cancelling  // 解禁解除申し込み中、会員有効、次月月初にはNotMemberになる。
		//FreePeriod, // 購入中、無償期間中、会員有効
	}
	public Status m_status = Status.Undef;

	public Passport(CheckLogin checkLogin) {
		if(checkLogin == null || !checkLogin.m_bLogin) return;

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM passport_logs WHERE user_id=? ORDER BY subscription_datetime DESC LIMIT 2";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, checkLogin.m_nUserId);
			cResSet = cState.executeQuery();

			if(cResSet.next()){
				m_nOrderId = cResSet.getInt("order_id");
				m_tsSubscription = cResSet.getTimestamp("subscription_datetime");
				m_tsRelease = cResSet.getTimestamp("cancel_datetime");

				// 1レコードだけだったら初回申込、
				// 2レコードあったら、「初回申込ではない」とする。
				m_bCancellationHistory = !cResSet.next();
			} else {
				m_bCancellationHistory = false;
			}

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		m_nUserId = checkLogin.m_nUserId;
		m_nPassportId = checkLogin.m_nPassportId;
		setStatus();
		errorKind = ErrorKind.None;
	}

	public boolean buy(int nPassportId, String strAgentToken, String strCardExpire,
					   String strCardSecurityCode, String strUserAgent) {
		if(m_status==Status.Undef){
			Log.d("m_status==Status.Undef");
			errorKind = ErrorKind.DoRetry;
			return false;
		}
		if(m_nPassportId==nPassportId){
			Log.d("m_nPassportId==nPassportId");
			errorKind = ErrorKind.DoRetry;
			return false;
		}
		if(nPassportId<=0){
			Log.d("nPassportId<=0");
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			int nProductId = -1;
			int nProdCatId = -1;
			String strProdName = null;
			int nListPrice = -1;
			strSql = "SELECT prod.id, prod.category_id, prod.name, prod.list_price FROM passports AS pass" +
					" INNER JOIN products AS prod ON pass.product_id=prod.id" +
					" WHERE pass.id=?;";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nPassportId);
			cResSet = cState.executeQuery();

			if(cResSet.next()){
				nProductId = cResSet.getInt(1);
				nProdCatId = cResSet.getInt(2);
				strProdName = cResSet.getString(3);
				nListPrice = cResSet.getInt(4);
			}else{
				Log.d("不正なpassport_id");
				errorKind = ErrorKind.DoRetry;
				return false;
			}
			cResSet.close();
			cState.close();

			strSql = "SELECT 1 FROM passport_logs WHERE user_id=? AND cancel_datetime IS NULL LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()){
				Log.d("二重に契約しようとした:" + m_nUserId);
				errorKind = ErrorKind.DoRetry;
				return false;
			}
			cResSet.close();
			cState.close();


			// 注文生成
			Order order = new Order();
			order.customerId = m_nUserId;
			order.sellerId = 2;
			order.paymentTotal = nListPrice;
			order.cheerPointStatus = Order.CheerPointStatus.NotApplicable;
			if (order.insert() != 0 || order.id < 0) {
				throw new Exception("insert order error");
			}

			OrderDetail orderDetail = new OrderDetail();
			orderDetail.orderId = order.id;
			orderDetail.productId = nProductId;
			orderDetail.productCategory = OrderDetail.ProductCategory.Passport;
			orderDetail.productName = strProdName;
			orderDetail.listPrice = nListPrice;
			orderDetail.amountPaid = nListPrice;
			orderDetail.quantity = 1;
			if (orderDetail.insert() != 0 || orderDetail.id < 0) {
				throw new Exception("insert order_detail error");
			}

			CardSettlement cardSettlement = new CardSettlementEpsilon(m_nUserId);
			cardSettlement.amount = nListPrice;
			cardSettlement.agentToken = strAgentToken;
			cardSettlement.cardExpire = strCardExpire;
			cardSettlement.cardSecurityCode = strCardSecurityCode;
			cardSettlement.userAgent = strUserAgent;
			cardSettlement.billingCategory = CardSettlement.BillingCategory.Monthly;
			boolean authorizeResult = cardSettlement.authorize();
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
			final int nCreditCardId = cardSettlement.creditcardIdToPay;

			//// begin transaction
			cConn.setAutoCommit(false);

			// insert into passport_logs
			strSql = "INSERT INTO passport_logs(user_id, subscription_datetime, cancel_datetime, order_id) VALUES (?, current_timestamp, null, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt (2, order.id);
			cState.executeUpdate();

			// update users_0000
			strSql = "UPDATE users_0000 SET passport_id=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nPassportId);
			cState.setInt(2, m_nUserId);
			cState.executeUpdate();

			// update orders
			strSql = "UPDATE orders SET creditcard_id=?, status=?, agency_order_id=?, updated_at=now() WHERE id=?";
			cState = cConn.prepareStatement(strSql);
			int idx=1;
			cState.setInt(idx++, nCreditCardId);
			cState.setInt(idx++,    authorizeResult ? Order.SettlementStatus.SettlementOk.getCode() : Order.SettlementStatus.SettlementError.getCode());
			cState.setString(idx++, authorizeResult ? cardSettlement.getAgentOrderId() : null);
			cState.setInt(idx++, order.id);
			cState.executeUpdate();

			cConn.commit();
			cConn.setAutoCommit(true);

			cState.close();cState=null;

			//// end transaction

			CacheUsers0000.getInstance().clearUser(m_nUserId);
			errorKind = ErrorKind.None;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
			return false;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		
		return true;
	}

	public boolean cancel() {
		if(m_tsRelease != null){
			Log.d("解約済み");
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			// 定期課金キャンセル
			CardSettlement cardSettlement = new CardSettlementEpsilon(m_nUserId);
			boolean authorizeResult = cardSettlement.cancelSubscription(m_nOrderId);
			if (!authorizeResult) {
				Log.d("cardSettlement.authorize() failed.");
				errorKind = ErrorKind.DoRetry;
				return false;
			}

			// update passport_logs
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			strSql = "UPDATE passport_logs SET cancel_datetime=current_timestamp WHERE user_id=? AND order_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nOrderId);
			cState.executeUpdate();
			cState.close();cState=null;
			cConn.close();cConn=null;

			/* users_0000は月末までそのまま。月初にスクリプトで更新 */

			errorKind = ErrorKind.None;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
			errorKind = ErrorKind.DoRetry;
			return false;
		} finally {
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}

		return true;
	}

	private void setStatus(){
		if (m_nUserId<0) {
			m_status = Status.Undef;
			return;
		}

		if (m_nPassportId <= 0) {
			m_status = Status.NotMember;
		} else {
			if (m_tsRelease != null) {
				m_status = Status.Cancelling;
			} else {
				m_status = Status.Billing;

				// 無償期間を設けるためのcode snippet.
//				LocalDateTime d = LocalDateTime.now();
//				final int nowYear = d.getYear();
//				final int nowMonth = d.getMonthValue();
//				final int sbscYear = m_tsSubscription.toLocalDateTime().getYear();
//				final int sbscMonth = m_tsSubscription.toLocalDateTime().getDayOfMonth();
//				if (!m_bCancellationHistory && nowYear == sbscYear && nowMonth == sbscMonth) {
//					m_status = Status.FreePeriod;
//				} else {
//					m_status = Status.Billing;
//				}
			}
		}
	}
}
