package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class ReactionsHasNotCheckedNotifier extends HasNotCheckedNotifier {
	public ReactionsHasNotCheckedNotifier() {
		infoType = InfoList.InfoType.Emoji;
		vmTemplateStatus = "reactions";
	}
}
