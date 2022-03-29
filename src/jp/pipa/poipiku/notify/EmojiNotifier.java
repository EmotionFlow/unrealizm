package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class EmojiNotifier extends Notifier {
	public EmojiNotifier(){
		vmTemplateCategory = "";
	}

	public void notifyReactionReceived(int toUserId, int contentId, int contentType, String emoji, String infoThumb){
		final User user = new User(toUserId);
		if (user.id > 0) {
			infoType = InfoList.InfoType.Emoji.getCode();
			notifyByWeb(user,
					-1,
					contentId,
					contentType,
					emoji,
					infoThumb,
					InsertMode.InsertBeforeReset);
			// notifyByApp(user, title);
		}
	}
	public void notifyReplyReceived(int toUserId, int contentId, int contentType, String emoji, String infoThumb){
		final User user = new User(toUserId);
		if (user.id > 0) {
			infoType = InfoList.InfoType.EmojiReply.getCode();
			notifyByWeb(user,
					-1,
					contentId,
					contentType,
					emoji,
					infoThumb,
					InsertMode.InsertBeforeReset);
			// notifyByApp(user, title);
		}
	}
}
