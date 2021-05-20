package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;

public class AcceptRequestC extends Controller{
	public boolean getResults(CheckLogin checkLogin, AcceptRequestCParam param) {
		if (param.requestId < 0) return false;
		if (!checkLogin.m_bLogin) return false;

		Request poipikuRequest = new Request(param.requestId);
		if (poipikuRequest.creatorUserId != checkLogin.m_nUserId) return false;

		CardSettlement settlement = new CardSettlementEpsilon(poipikuRequest.clientUserId);
		boolean captureResult = settlement.capture(poipikuRequest.orderId);
		if (!captureResult) {
			if (settlement.errorKind == CardSettlement.ErrorKind.CardAuth) {
				errorKind = ErrorKind.CardAuth;
				poipikuRequest.updateStatus(Request.Status.SettlementError);
			} else {
				errorKind = ErrorKind.DoRetry;
			}
			return false;
		}

		if (!poipikuRequest.accept()) {
			errorKind = ErrorKind.Unknown;
			return false;
		}

		Order order = new Order();
		order.selectById(poipikuRequest.orderId);
		if (!order.capture()) {
			errorKind = ErrorKind.NeedInquiry;
			return false;
		}

		RequestNotifier notifier = new RequestNotifier();
		notifier.notifyRequestAccepted(poipikuRequest);
		errorKind = ErrorKind.None;
		return true;
	}
}
