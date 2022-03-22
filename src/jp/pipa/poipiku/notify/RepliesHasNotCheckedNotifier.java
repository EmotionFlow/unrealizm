package jp.pipa.poipiku.notify;

import jp.pipa.poipiku.InfoList;

public final class RepliesHasNotCheckedNotifier extends HasNotCheckedNotifier {

	public RepliesHasNotCheckedNotifier() {
		infoType = InfoList.InfoType.EmojiReply;
		vmTemplateStatus = "replies";
	}
}
