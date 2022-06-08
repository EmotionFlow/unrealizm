package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class WaveRepliesHasNotCheckedNotifier extends HasNotCheckedNotifier {
	public WaveRepliesHasNotCheckedNotifier() {
		infoType = InfoList.InfoType.WaveEmojiMessageReply;
		vmTemplateStatus = "wave_replies";
		remindDay = 1;
	}
}
