package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.notify.RequestNotifier;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class SendRequestC extends Controller {
	public int clientUserId = -1;
	public int creatorUserId = -1;
	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int anonymous = -1;
	public int licenseId = -1;
	public int paidRequest = -1;
	public int amount = -1;
	public int commission = -1;
	public int paymentMethodId = -1;
	public int agentId = -1;
	public String ipAddress = "";
	public String agentToken = "";
	public String cardExpire = "";
	public String userAgent = "";


	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			clientUserId = Util.toInt(request.getParameter("CLIENT"));
			creatorUserId = Util.toInt(request.getParameter("CREATOR"));
			mediaId = Util.toInt(request.getParameter("MEDIA"));
			requestText = Common.TrimAll(request.getParameter("TEXT"));
			requestCategory = Util.toInt(request.getParameter("CATEGORY"));
			anonymous = Util.toInt(request.getParameter("ANONYMOUS"));
			licenseId = Util.toInt(request.getParameter("LICENSE"));
			paidRequest = Util.toInt(request.getParameter("PAID_REQUEST"));
			amount = Util.toInt(request.getParameter("AMOUNT"));
			commission = Util.toInt(request.getParameter("COMMISSION"));
			paymentMethodId = Util.toInt(request.getParameter("PAYMENT_METHOD"));
			agentId = Util.toInt(request.getParameter("AID"));
			agentToken = Util.toString(request.getParameter("TKN"));
			cardExpire	= Util.toString(request.getParameter("EXP"));
			userAgent  = request.getHeader("user-agent");
			ipAddress = request.getRemoteAddr();
		} catch(Exception e) {
			clientUserId = -1;
			creatorUserId = -1;
		}
	}

	private int calcCommission() {
		return amount *
				(Request.SYSTEM_COMMISSION_RATE_PER_MIL
						+ Request.AGENCY_COMMISSION_RATE_CREDITCARD_PER_MIL) / 1000;
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != clientUserId) {
			errorKind = ErrorKind.Unknown;
			return false;
		}

		// 送信数リミットにかかっていたらエラー
		if (Request.isReachedSendLimit(clientUserId)) {
			Log.d("エアスケブ依頼の送信リミットにかかった:" + clientUserId);
			errorKind = ErrorKind.Unknown;
			return false;
		}

		// 手数料検証
		if (commission != calcCommission()) {
			Log.d("クライアントに提示している手数料とサーバ側で計算した手数料が異なる");
			Log.d(String.format("amount: %d, commission:%d", commission, calcCommission()));
			Log.d(String.format("cli: %d, srv:%d", commission, calcCommission()));
			errorKind = ErrorKind.Unknown;
			return false;
		}

		// 想定外の依頼がされたかチェック
		RequestCreator requestCreator = new RequestCreator(creatorUserId);
		if (requestCreator.status != RequestCreator.Status.Enabled) {
			Log.d("受付していないユーザーへのエアスケブ依頼:" + clientUserId);
			errorKind = ErrorKind.Unknown;
			return false;
		}
		if (!requestCreator.allowFreeRequest && paidRequest == 0 || !requestCreator.allowPaidRequest && paidRequest == 1) {
			Log.d("受付していない形式（有償・無償）のエアスケブ依頼:" + clientUserId);
			errorKind = ErrorKind.Unknown;
			return false;
		}

		// 金額チェック
		if (paidRequest == 1) {
			if (requestCreator.amountMinimum > amount || RequestCreator.AMOUNT_LEFT_TO_ME_MAX < amount) {
				Log.d("有償依頼の金額が範囲外");
				errorKind = ErrorKind.Unknown;
				return false;
			}
		} else {
			if (amount != 0) {
				Log.d("無償依頼であるのに0円でない");
				errorKind = ErrorKind.Unknown;
				return false;
			}
		}


		// TODO 依頼回数制限

		Request poipikuRequest = new Request();
		poipikuRequest.clientUserId = clientUserId;
		poipikuRequest.creatorUserId = creatorUserId;
		poipikuRequest.isClientAnonymous = anonymous == 1;
		poipikuRequest.mediaId = mediaId;
		poipikuRequest.requestText = requestText;
		poipikuRequest.requestCategory = requestCategory;
		poipikuRequest.licenseId = licenseId;
		poipikuRequest.amount = amount;

		boolean insertResult = poipikuRequest.insert();
		if (!insertResult) {
			Log.d(String.format("Request.insert error: %d", poipikuRequest.errorKind.getCode()));
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		// 決済処理
		if (paidRequest == 1) {
			Order order = new Order();
			order.customerId = clientUserId;
			order.sellerId = creatorUserId;
			order.paymentTotal = amount + commission;
			order.commission = commission;
			order.commissionRateSystemPerMil = Request.SYSTEM_COMMISSION_RATE_PER_MIL;
			order.commissionRateAgencyPerMil = Request.AGENCY_COMMISSION_RATE_CREDITCARD_PER_MIL;
			order.cheerPointStatus = Order.CheerPointStatus.NotApplicable;
			if (order.insert() != 0 || order.id < 0) {
				errorKind = ErrorKind.DoRetry;
				return false;
			}
			OrderDetail orderDetail = new OrderDetail();
			orderDetail.orderId = order.id;
			orderDetail.requestId = poipikuRequest.id;
			orderDetail.productCategory = OrderDetail.ProductCategory.Request;
			orderDetail.productName = "REQUEST";
			orderDetail.listPrice = amount;
			orderDetail.amountPaid = amount;
			orderDetail.quantity = 1;
			if (orderDetail.insert() != 0 || orderDetail.id < 0) {
				errorKind = ErrorKind.DoRetry;
				return false;
			}

			CardSettlement cardSettlement = new CardSettlementEpsilon(clientUserId);
			cardSettlement.requestId = poipikuRequest.id;
			cardSettlement.poipikuOrderId = order.id;
			cardSettlement.amount = order.paymentTotal;
			cardSettlement.agentToken = agentToken;
			cardSettlement.cardExpire = cardExpire;
			cardSettlement.userAgent = userAgent;
			cardSettlement.billingCategory = CardSettlement.BillingCategory.AuthorizeOnly;
			cardSettlement.itemName = CardSettlement.ItemName.Request;

			boolean authorizeResult = cardSettlement.authorize();

			Order.Status newStatus;
			if (authorizeResult) {
				newStatus = Order.Status.BeforeCapture;
			} else {
				newStatus = Order.Status.SettlementError;
			}

			boolean updateOrderResult = order.update(
					newStatus,
					cardSettlement.orderId,
					cardSettlement.creditCardIdToPay);

			if (newStatus == Order.Status.SettlementError){
				if (cardSettlement.errorKind == CardSettlement.ErrorKind.CardAuth) {
					errorKind = ErrorKind.CardAuth;
				} else if(cardSettlement.errorKind == CardSettlement.ErrorKind.NeedInquiry) {
					errorKind = ErrorKind.NeedInquiry;
				} else {
					errorKind = ErrorKind.DoRetry;
				}
				return false;
			}
			if (!updateOrderResult) {
				errorKind = ErrorKind.DoRetry;
				return false;
			}
			if (!poipikuRequest.send(order.id)) {
				errorKind = ErrorKind.DoRetry;
				return false;
			}
		} else {
			if (!poipikuRequest.send()) {
				errorKind = ErrorKind.DoRetry;
				return false;
			}
		}

		RequestNotifier notifier = new RequestNotifier();
		notifier.notifyRequestReceived(poipikuRequest);

		return true;
	}
}
