package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;
import jp.pipa.poipiku.Request;
import jp.pipa.poipiku.RequestNotifier;

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

		// TODO client決済

		if (poipikuRequest.accept() == 0) {
			RequestNotifier.notifyRequestAccepted(poipikuRequest);
			errorCode = ERR_NONE;
			result = true;
		}

		return result;
	}
}
