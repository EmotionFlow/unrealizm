package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.Log;

public class DeliverRequestC extends Controller{
	private CheckLogin checkLogin;
	private Request poipikuRequest;
	DeliverRequestC(final CheckLogin _checkLogin, final int requestId) {
		checkLogin = _checkLogin;
		poipikuRequest = new Request(requestId);
		if (poipikuRequest.creatorUserId != checkLogin.m_nUserId) {
			errorKind = ErrorKind.Unknown;
			Log.d(String.format("クリエイターではないユーザーによる不正アクセス %d, %d, %d", poipikuRequest.id, poipikuRequest.creatorUserId, checkLogin.m_nUserId));
		} else {
			errorKind = ErrorKind.None;
		}
	}
	public boolean getResults(final int contentId) {
		if (checkLogin == null || poipikuRequest == null || errorKind != ErrorKind.None) {
			return false;
		}
		if (!checkLogin.m_bLogin) return false;

		CheerPoint cheerPoint = new CheerPoint();
		cheerPoint.userId = poipikuRequest.creatorUserId;
		cheerPoint.acquisitionPoints = poipikuRequest.amount;
		if (cheerPoint.insert() < 0){
			Log.d("ポチ袋付与エラー");
			errorKind = ErrorKind.Unknown;
			return false;
		}

		if (!poipikuRequest.deliver(contentId)) {
			errorKind = ErrorKind.Unknown;
			return false;
		}

		RequestNotifier notifier = new RequestNotifier();
		notifier.notifyRequestDelivered(poipikuRequest);
		errorKind = ErrorKind.None;
		return true;
	}
}
