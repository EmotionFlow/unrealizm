package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;

public class AcceptRequestC {
	public final int ERR_NONE = 0;
	public final int ERR_RETRY = -10;
	public final int ERR_INQUIRY = -20;
	public final int ERR_CARD_AUTH = -30;
	public final int ERR_UNKNOWN = -99;

	public int errorCode = ERR_UNKNOWN;

	public boolean getResults(CheckLogin checkLogin, AcceptRequestCParam param) {
		if (param.requestId < 0) return false;
		if (!checkLogin.m_bLogin) return false;

		boolean result = false;

		Request poipikuRequest = new Request(param.requestId);
		if (poipikuRequest.creatorUserId != checkLogin.m_nUserId) return false;

		if (poipikuRequest.accept() == 0) {
			if (!checkLogin.m_bLogin || poipikuRequest.amount <= 0) {
				return false;
			}

			// TODO 仮売上を本売上に更新


			RequestNotifier.notifyRequestAccepted(poipikuRequest);
			errorCode = ERR_NONE;
			result = true;
		}

		return result;
	}
}
