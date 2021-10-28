package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.util.Log;

public class User {
	private final int poipikuUserId;
	private final String epsilonUserId;

	public User(int _poipikuUserId, String _epsilonUserId) {
		poipikuUserId = _poipikuUserId;
		epsilonUserId = _epsilonUserId;
	}

	public boolean deleteUserInfo() {
		SettlementSendInfo ssi = new SettlementSendInfo();
		ssi.userId = epsilonUserId;
		ssi.processCode = 9; // 退会
		ssi.memo1 = "DUMMY";
		ssi.memo2 = "DUMMY";
		ssi.xml = 1;

		EpsilonSettlementAuthorize epsilonSettlementAuthorize = new EpsilonSettlementAuthorize(poipikuUserId, ssi);
		SettlementResultInfo settlementResultInfo = epsilonSettlementAuthorize.execSettlement();
		if (settlementResultInfo != null) {
			String settlementResultCode = settlementResultInfo.result;
			Log.d("settlementResultInfo: " + settlementResultInfo.toString());
			return "1".equals(settlementResultCode);
		} else {
			return false;
		}
   }
}
