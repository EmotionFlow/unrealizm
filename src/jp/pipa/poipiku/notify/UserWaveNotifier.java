package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.SupportedLocales;

import java.util.Locale;

public final class UserWaveNotifier extends Notifier {
	public UserWaveNotifier(){
		vmTemplateCategory = "";
	}

	public void notifyWaveReceived(int toUserId, String emoji){
		final User user = new User(toUserId);
		if (user.id > 0) {
			infoType = InfoList.InfoType.WaveEmoji.getCode();
			notifyByWeb(user,
					-1,
					-1,
					-1,
					emoji,
					"",
					InsertMode.InsertBeforeReset);
		}
		final Locale locale = SupportedLocales.findLocale(user.langId);
		final String body = ResourceBundleControl.T(locale,"ActivityList.Message.WaveEmoji");
		notifyByApp(user, body, true);
	}

	public void notifyWaveMessageReceived(int toUserId, String emoji, String message){
		final User user = new User(toUserId);
		if (user.id > 0) {
			infoType = InfoList.InfoType.WaveEmojiMessage.getCode();
			notifyByWeb(user,
					-1,
					-1,
					-1,
					emoji,
					"",
					InsertMode.InsertBeforeReset);
		}
		final Locale locale = SupportedLocales.findLocale(user.langId);
		final String body = ResourceBundleControl.T(locale,"ActivityList.Message.WaveEmojiMessage");
		notifyByApp(user, body, true);
	}

	public void notifyWaveMessageReplyReceived(int receivedUserId, String emoji){
		final User user = new User(receivedUserId);
		if (user.id > 0) {
			infoType = InfoList.InfoType.WaveEmojiMessageReply.getCode();
			notifyByWeb(user,
					-1,
					-1,
					-1,
					emoji,
					"",
					InsertMode.InsertBeforeReset);
		}
		final Locale locale = SupportedLocales.findLocale(user.langId);
		final String body = ResourceBundleControl.T(locale,"ActivityList.Message.WaveEmojiMessageReply");
		notifyByApp(user, body, true);
	}
}
