package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

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
	}
}
