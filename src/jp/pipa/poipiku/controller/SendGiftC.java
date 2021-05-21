package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SendGiftC {
	public static final int ERR_NONE = 0;
	public static final int ERR_RETRY = -10;
	public static final int ERR_INQUIRY = -20;
	public static final int ERR_CARD_AUTH = -30;
	public static final int ERR_UNKNOWN = -99;

	public int toUserId = -1;
	public int m_nAgentId = -1;
	public String m_strAgentToken = "";
	public String m_strIpAddress = "";
	public String m_strCardExpire = "";
	public String m_strCardSecurityCode = "";
	public int m_nErrCode = ERR_UNKNOWN;
	public String m_strUserAgent = "";

	private static final int AMOUNT = 300;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			toUserId	= Util.toInt(request.getParameter("TOID"));
			m_nAgentId		= Util.toInt(request.getParameter("AID"));
			m_strIpAddress	= request.getRemoteAddr();
			m_strAgentToken = Util.toString(request.getParameter("TKN"));
			m_strCardExpire	= Util.toString(request.getParameter("EXP"));
			m_strCardSecurityCode	= Util.toString(request.getParameter("SEC"));
			m_strUserAgent  = request.getHeader("user-agent");
		} catch(Exception e) {
			toUserId = -1;
		}
	}

	public boolean getResults(final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
		if(!checkLogin.m_bLogin  || toUserId<0) return false;

		final int fromUserId = checkLogin.m_nUserId;
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// 相手ユーザー存在確認
			sql = "SELECT 1 FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, toUserId);
			resultSet = statement.executeQuery();
			if (!resultSet.next()) {
				Log.d("存在しないユーザへの差し入れ");
				return false;
			}

			// 注文生成
			Order order = new Order();
			order.customerId = fromUserId;
			order.sellerId = 2; // ポイピク公式
			order.paymentTotal = AMOUNT;
			order.cheerPointStatus = Order.CheerPointStatus.NotApplicable;
			if (order.insert() != 0 || order.id < 0) {
				throw new Exception("insert order error");
			}

			OrderDetail orderDetail = new OrderDetail();
			orderDetail.orderId = order.id;
			orderDetail.contentId = -1;
			orderDetail.productCategory = OrderDetail.ProductCategory.Passport;
			orderDetail.contentUserId = -1;
			orderDetail.productName = "GIFT";
			orderDetail.listPrice = AMOUNT;
			orderDetail.amountPaid = AMOUNT;
			orderDetail.quantity = 1;
			if (orderDetail.insert() != 0 || orderDetail.id < 0) {
				throw new Exception("insert order_detail error");
			}

			CardSettlement cardSettlement = new CardSettlementEpsilon(fromUserId);
			cardSettlement.contentId = -1;
			cardSettlement.poipikuOrderId = order.id;
			cardSettlement.amount = AMOUNT;
			cardSettlement.agentToken = m_strAgentToken;
			cardSettlement.cardExpire = m_strCardExpire;
			cardSettlement.cardSecurityCode = m_strCardSecurityCode;
			cardSettlement.userAgent = m_strUserAgent;
			cardSettlement.billingCategory = CardSettlement.BillingCategory.OneTime;
			cardSettlement.itemName = CardSettlement.ItemName.Gift;

			boolean authorizeResult = cardSettlement.authorize();

			order.update(
					authorizeResult ? Order.Status.SettlementOk : Order.Status.SettlementError,
					authorizeResult ? cardSettlement.getAgentOrderId() : null,
					authorizeResult ? cardSettlement.creditcardIdToPay : null);
			if(!authorizeResult){
				setErrCode(cardSettlement);
				return false;
			}

			PoiTicketGiftLog giftLog = new PoiTicketGiftLog();
			giftLog.fromUserId = fromUserId;
			giftLog.toUserId = toUserId;
			giftLog.orderId = order.id;
			giftLog.insert();

			Passport passport = new Passport(toUserId);
			if (passport.status == Passport.Status.Active) {
				// すでにポイパス加入していたら、チケット１枚追加
				PoiTicket ticket = new PoiTicket(toUserId);
				ticket.add(1);
			} else {
				// ポイパスに加入していなかったら、ポイパスONする（チケットは追加しない）
				if (!passport.exists) {
					passport.courseId = 1;
					passport.insert();
				}
				passport.activate();
			}

			m_nErrCode = ERR_NONE;
			bRtn = true;

			GiftNotifier notifier = new GiftNotifier();
			notifier.notifyGiftReceived(toUserId);

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}

	private void setErrCode(CardSettlement cardSettlement) {
		if(cardSettlement.errorKind == CardSettlement.ErrorKind.CardAuth){
			m_nErrCode = ERR_CARD_AUTH;
		}else if(cardSettlement.errorKind == CardSettlement.ErrorKind.Common){
			m_nErrCode = ERR_RETRY;
		}else if(cardSettlement.errorKind == CardSettlement.ErrorKind.NeedInquiry){
			m_nErrCode = ERR_INQUIRY; // 決済されてるかもしれないし、されていないかもしれない。
		}else{
			m_nErrCode = ERR_UNKNOWN;
		}
	}

}
