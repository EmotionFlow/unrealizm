package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.UserWaveTemplate;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateUserWaveEnableC {
	public int userId = -1;
	public int enable = -1;
	public int commentEnable = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			enable = Util.toInt(request.getParameter("ENABLE"));
			commentEnable = Util.toInt(request.getParameter("CMTENABLE"));
		} catch(Exception ignored) {
			;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (checkLogin.m_nUserId != userId) {
			return false;
		}

//		Log.d("uid, en, cm, %d, %d, %d".formatted(userId, enable, commentEnable));

		if (enable >= 0) {
			if (enable == 0) {
				UserWaveTemplate.disable(userId);
			} else {
				UserWaveTemplate.enable(userId);
			}
		}

		if (commentEnable >= 0) {
			if (commentEnable == 0) {
				UserWaveTemplate.disableComment(userId);
			} else {
				UserWaveTemplate.enableComment(userId);
			}
		}

		return true;
	}
}
