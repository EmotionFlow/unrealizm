package jp.pipa.poipiku;

public final class GiftNotifier extends Notifier{
	public GiftNotifier(){
		CATEGORY = "gift_passport";
		NOTIFICATION_INFO_TYPE = Common.NOTIFICATION_TYPE_GIFT;
	}

	public void notifyGiftReceived(int toUserId){
		final User user = new User(toUserId);
		final String statusName = "received";
		if (user.id > 0) {
			final String title = getTitle(statusName, user.langLabel);
			notifyByWeb(user, -1, -1, Common.CONTENT_TYPE_TEXT, title);
			notifyByApp(user, title);
		}
	}
}
