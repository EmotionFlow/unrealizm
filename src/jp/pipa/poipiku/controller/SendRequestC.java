package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class SendRequestC {
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

	public int getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != clientUserId) {
			return -1;
		}
		Request poipikuRequest = new Request();
		poipikuRequest.clientUserId = clientUserId;
		poipikuRequest.creatorUserId = creatorUserId;
		poipikuRequest.mediaId = mediaId;
		poipikuRequest.requestText = requestText;
		poipikuRequest.requestCategory = requestCategory;
		poipikuRequest.amount = amount;
		int requestResult = poipikuRequest.insert();

		if (requestResult != 0) {
			return requestResult;
		}
		Order order = new Order();
		order.customerId = poipikuRequest.clientUserId;
		order.sellerId = poipikuRequest.creatorUserId;
		order.paymentTotal = poipikuRequest.amount;
		order.cheerPointStatus = Order.CheerPointStatus.NotApplicable;
		if (order.insert() != 0 || order.id < 0) {
			return -2;
		}
		OrderDetail orderDetail = new OrderDetail();
		orderDetail.orderId = order.id;
		orderDetail.requestId = poipikuRequest.id;
		orderDetail.productCategory = OrderDetail.ProductCategory.Request;
		orderDetail.productName = "REQUEST";
		orderDetail.listPrice = poipikuRequest.amount;
		orderDetail.amountPaid = poipikuRequest.amount;
		orderDetail.quantity = 1;
		if (orderDetail.insert() != 0 || orderDetail.id < 0) {
			return -3;
		}

		CardSettlement cardSettlement = new CardSettlementEpsilon(poipikuRequest.clientUserId);
		cardSettlement.requestId = poipikuRequest.id;
		cardSettlement.poipikuOrderId = order.id;
		cardSettlement.amount = poipikuRequest.amount;
		cardSettlement.agentToken = agentToken;
		cardSettlement.cardExpire = cardExpire;
		cardSettlement.cardSecurityCode = cardSecurityCode;
		cardSettlement.userAgent = userAgent;
		cardSettlement.billingCategory = CardSettlement.BillingCategory.AuthorizeOnly;

		boolean authorizeResult = cardSettlement.authorize();

		Order.SettlementStatus newStatus;
		if (authorizeResult) {
			newStatus = Order.SettlementStatus.BeforeCapture;
		} else {
			newStatus = Order.SettlementStatus.SettlementError;
		}

		int updateResult = order.updateSettlementStatus(
							newStatus,
							cardSettlement.orderId,
							cardSettlement.creditcardIdToPay);

		if (newStatus == Order.SettlementStatus.SettlementError){
			return -4;
		}
		if (updateResult != 0) {
			return -5;
		}

		RequestNotifier.notifyRequestReceived(poipikuRequest);
		return 0;
	}
}
