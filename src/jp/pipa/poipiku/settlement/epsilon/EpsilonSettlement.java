package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.SlackNotifier;

public abstract class EpsilonSettlement {
	protected static final String CONTRACT_CODE = "XXXXXXX";
	enum ConnectTo {
		Dev, Prod
	}
	protected ConnectTo connectTo = ConnectTo.Prod;
	protected EpsilonSettlement(int poipikuUserId) {
		if (CheckLogin.isStaff(poipikuUserId) || Common.isDevEnv()) {
			connectTo = ConnectTo.Dev;
		} else {
			connectTo = ConnectTo.Prod;
		}
	}
	protected void notifyErrorToSlack(String message) {
		SlackNotifier slackNotifier = new SlackNotifier(Common.SLACK_WEBHOOK_ERROR);
		slackNotifier.notify(message);
	}
}
