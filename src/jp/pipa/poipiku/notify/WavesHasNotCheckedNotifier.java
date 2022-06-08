package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class WavesHasNotCheckedNotifier extends HasNotCheckedNotifier {
	public WavesHasNotCheckedNotifier() {
		infoType = InfoList.InfoType.WaveEmoji;
		vmTemplateStatus = "waves";
		remindDay = 5;
	}
}
