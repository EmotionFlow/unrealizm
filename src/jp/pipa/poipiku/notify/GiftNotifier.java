package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.Common;

public final class GiftNotifier extends Notifier {
	public GiftNotifier(){
		vmTemplateCategory = "gift_passport";
		infoType = Common.NOTIFICATION_TYPE_GIFT;
	}

	public void notifyGiftReceived(int toUserId){
		final User user = new User(toUserId);
		final String statusName = "received";
		if (user.id > 0) {
			final String title = getTitle(statusName, user.langLabel);
			notifyByWeb(user, -1, (int) Math.ceil(Math.random() * -10000000),
					Common.CONTENT_TYPE_TEXT, title, "", InsertMode.Upsert);
			notifyByApp(user, title);
		}
	}
}
