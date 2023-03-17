package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.UserWaveTemplate;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateUserWaveEmojiC {
	static public final int MAX_EMOJI_NUM = 4;
	public int userId = -1;
	public String emoji = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			emoji = Util.toString(request.getParameter("EMOJI"));
		} catch(Exception ignored) {
			;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (checkLogin.m_nUserId != userId) {
			return false;
		}

		int dispOrder = 0;

		// サロゲート文字で４バイト文字を判定
		// 正しく１文字ずつ切り出す
		final String upperSurStart = "d800";
		final String upperSurEnd = "dbff";
		for (int i = 0; i < emoji.length(); i++) {
			int code = emoji.charAt(i);
			String hex = Integer.toHexString(code);
			String oneEmoji = "";
			if (hex.compareTo(upperSurStart) >= 0 &&
					hex.compareTo(upperSurEnd) <= 0) {
				oneEmoji = emoji.substring(i, i + 2);
				i++;
			} else {
				oneEmoji = emoji.substring(i, i + 1);
			}
			UserWaveTemplate.upsert(userId, dispOrder++, oneEmoji);
			if (dispOrder >= MAX_EMOJI_NUM) break;
		}

		for (int order=dispOrder; order<MAX_EMOJI_NUM; order++) {
			UserWaveTemplate.delete(userId, order);
		}

		return true;
	}
}
