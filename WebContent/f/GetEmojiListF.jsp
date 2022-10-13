<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
StringBuilder sbResult = new StringBuilder();
GetEmojiListC cResults = new GetEmojiListC();
cResults.getParam(request);
if(!checkLogin.m_bLogin && cResults.categoryId ==Emoji.EMOJI_CAT_RECENT) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.Recent.NeedLogin")));
} else if(!checkLogin.m_bLogin && cResults.categoryId ==Emoji.EMOJI_CAT_OTHER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("IllustV.Emoji.All.NeedLogin")));
} else if(!checkLogin.m_bLogin && cResults.categoryId ==Emoji.EMOJI_CAT_CHEER) {
	sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.NeedLogin")));
} else {
	String[] EMOJI_LIST = cResults.getResults(checkLogin);
	if(Emoji.EMOJI_EVENT) {
		EMOJI_LIST = Emoji.EMOJI_EVENT_LIST;
	}
	if(cResults.categoryId ==Emoji.EMOJI_CAT_CHEER && cResults.cheerNg) {
		sbResult.append(String.format("<span class=\"NeedLogin\">%s</span>", _TEX.T("Cheer.Ng")));
	} else {
		String emoji;
		for(int i=0; i<EMOJI_LIST.length; i++) {
			if (cResults.miniList && i >= GridUtil.SELECT_MINI_LIST_EMOJI - 1) break;
			emoji = EMOJI_LIST[i];
			sbResult.append(
					String.format("<span class=\"ResEmojiBtn\" onclick=\"SendEmoji(%d, '%s', %d, this)\">%s</span>",
							cResults.contentId,
							emoji,
							checkLogin.m_nUserId,
							CEmoji.parse(emoji))
					);
		}
	}
}
%>
<%=sbResult.toString()%>
