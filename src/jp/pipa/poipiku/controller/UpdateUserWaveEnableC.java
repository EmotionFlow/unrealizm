package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.UserWaveTemplate;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateUserWaveEnableC {
	public int userId = -1;
	public int enable = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			enable = Util.toInt(request.getParameter("ENABLE"));
		} catch(Exception ignored) {
			;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (checkLogin.m_nUserId != userId || !(enable == 0 || enable == 1)) {
			return false;
		}

		if (enable == 0) {
			UserWaveTemplate.disable(userId);
		} else {
			UserWaveTemplate.enable(userId);
		}

		return true;
	}
}
