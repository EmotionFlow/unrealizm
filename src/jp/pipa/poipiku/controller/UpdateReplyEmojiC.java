package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.CommentTemplate;
import jp.pipa.poipiku.Emoji;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.util.Arrays;

public class UpdateReplyEmojiC {
	public int userId = -1;
	public int dispOrder = 0;
	public String emoji = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			dispOrder = Util.toInt(request.getParameter("ORDER"));
			emoji = Util.toString(request.getParameter("EMOJI"));
		} catch(Exception ignored) {
			;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (checkLogin.m_nUserId != userId || !Arrays.asList(Emoji.EMOJI_ALL).contains(emoji)) {
			return false;
		} else {
			return CommentTemplate.upsert(userId, dispOrder, emoji);
		}
	}
}
