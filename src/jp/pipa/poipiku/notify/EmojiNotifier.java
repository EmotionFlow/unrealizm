package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.SupportedLocales;
import java.util.Locale;

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

			final Locale locale = SupportedLocales.findLocale(user.langId);
			final String body = ResourceBundleControl.T(locale,"ActivityList.Message.Comment");
			notifyByApp(user, body, true);
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
