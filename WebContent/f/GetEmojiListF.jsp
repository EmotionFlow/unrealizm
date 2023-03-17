<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
StringBuilder sbResult = new StringBuilder();
GetEmojiListC results = new GetEmojiListC();
results.getParam(request);
if(!checkLogin.m_bLogin && results.categoryId ==Emoji.EMOJI_CAT_RECENT) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.Recent.NeedLogin")));
} else if(!checkLogin.m_bLogin && results.categoryId ==Emoji.EMOJI_CAT_OTHER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.All.NeedLogin")));
} else if(!checkLogin.m_bLogin && results.categoryId ==Emoji.EMOJI_CAT_RANDOM) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.Recent.NeedLogin")));
} else if(!checkLogin.m_bLogin && results.categoryId ==Emoji.EMOJI_CAT_CHEER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.NeedLogin")));
} else {
	String[] EMOJI_LIST = results.getResults(checkLogin);
	if(Emoji.EMOJI_EVENT) {
		EMOJI_LIST = Emoji.EMOJI_EVENT_LIST;
	}

	boolean[] pickIdx = null;
	if (results.categoryId == Emoji.EMOJI_CAT_RANDOM && EMOJI_LIST.length > Emoji.EMOJI_KEYBOARD_MINI) {
		pickIdx = new boolean[EMOJI_LIST.length];
		int pickNum = 0;
		int i;
		Random random = new Random();
		while (pickNum < Emoji.EMOJI_KEYBOARD_MINI) {
			i = random.nextInt(EMOJI_LIST.length);
			if (!pickIdx[i]) {
				pickIdx[i] = true;
				pickNum++;
			}
		}
	}

	if(results.categoryId == Emoji.EMOJI_CAT_CHEER && results.cheerNg) {
		sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.Ng")));
	} else {
		String emoji;

		if (pickIdx==null) {
			for(int i=0; i<EMOJI_LIST.length; i++) {
				if (results.miniList && i >= Emoji.EMOJI_KEYBOARD_MINI) break;
				emoji = EMOJI_LIST[i];
				sbResult.append(
						String.format("<span class=\"ResEmojiBtn\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</span>",
								results.contentId,
								emoji,
								checkLogin.m_nUserId,
								CEmoji.parse(emoji))
				);
			}
		} else {
			for(int i=0; i<EMOJI_LIST.length; i++) {
				if (!pickIdx[i]) continue;
				emoji = EMOJI_LIST[i];
				sbResult.append(
						String.format("<span class=\"ResEmojiBtn\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</span>",
								results.contentId,
								emoji,
								checkLogin.m_nUserId,
								CEmoji.parse(emoji))
				);
			}
		}
	}
}
%>
<%=sbResult.toString()%>
