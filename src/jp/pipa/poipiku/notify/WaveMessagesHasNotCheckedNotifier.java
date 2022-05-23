package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class WaveMessagesHasNotCheckedNotifier extends HasNotCheckedNotifier {
	public WaveMessagesHasNotCheckedNotifier() {
		infoType = InfoList.InfoType.WaveEmojiMessage;
		vmTemplateStatus = "wave_messages";
		remindDay = 1;
	}
}
