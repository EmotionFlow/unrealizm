package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;

public abstract class EpsilonSettlement {
	protected static final String CONTRACT_CODE = "68968190";
	enum ConnectTo {
		Dev, Prod
	};
	protected ConnectTo connectTo = ConnectTo.Prod;
	protected EpsilonSettlement(int poipikuUserId) {
		if (CheckLogin.isStaff(poipikuUserId) || Common.isDevEnv()) {
			connectTo = ConnectTo.Dev;
		} else {
			connectTo = ConnectTo.Prod;
		}
	}
}
