package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
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
	public int amount = -1;
	public int agentId = -1;
	public String ipAddress = "";
	public String agentToken = "";
	public String cardExpire = "";
	public String cardSecurityCode = "";
	public String userAgent = "";


	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			clientUserId = Util.toInt(request.getParameter("CLIENT"));
			creatorUserId = Util.toInt(request.getParameter("CREATOR"));
			mediaId = Util.toInt(request.getParameter("MEDIA"));
			requestText = Common.TrimAll(request.getParameter("TEXT"));
			requestCategory = Util.toInt(request.getParameter("CATEGORY"));
			amount = Util.toInt(request.getParameter("AMOUNT"));
			agentId = Util.toInt(request.getParameter("AID"));
			agentToken = Util.toString(request.getParameter("TKN"));
			cardExpire	= Util.toString(request.getParameter("EXP"));
			cardSecurityCode	= Util.toString(request.getParameter("SEC"));
			userAgent  = request.getHeader("user-agent");
			ipAddress = request.getRemoteAddr();
		} catch(Exception e) {
			clientUserId = -1;
			creatorUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != clientUserId) {
			errorKind = ErrorKind.Unknown;
			return false;
		}
		Request poipikuRequest = new Request();
		poipikuRequest.clientUserId = clientUserId;
		poipikuRequest.creatorUserId = creatorUserId;
		poipikuRequest.mediaId = mediaId;
		poipikuRequest.requestText = requestText;
		poipikuRequest.requestCategory = requestCategory;
		poipikuRequest.amount = amount;

		boolean insertResult = poipikuRequest.insert();
		if (!insertResult) {
			Log.d(String.format("Request.insert error: %d", poipikuRequest.errorKind.getCode()));
			errorKind = ErrorKind.DoRetry;
			return false;
		}

		Order order = new Order();
		order.customerId = clientUserId;
		order.sellerId = creatorUserId;
		order.paymentTotal = amount;
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
		cardSettlement.amount = amount;
		cardSettlement.agentToken = agentToken;
		cardSettlement.cardExpire = cardExpire;
		cardSettlement.cardSecurityCode = cardSecurityCode;
		cardSettlement.userAgent = userAgent;
		cardSettlement.billingCategory = CardSettlement.BillingCategory.AuthorizeOnly;

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
				cardSettlement.creditcardIdToPay);

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

		RequestNotifier.notifyRequestReceived(poipikuRequest);

		return true;
	}
}
