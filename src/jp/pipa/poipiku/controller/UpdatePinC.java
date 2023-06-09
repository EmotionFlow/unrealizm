package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Pin;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public class UpdatePinC {
	public static final int UNKNOWN_ERROR = -1;
	public static final int USER_INVALID = -2;
	public static final int PIN_REMOVED = 0;
	public static final int PIN_ADDED = 1;
	public static final int PIN_UPDATED = 2;

	public int userId = -1;
	public int contentId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			contentId = Util.toInt(request.getParameter("IID"));
		} catch(Exception e) {
			userId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!= userId) return USER_INVALID;

		int result = UNKNOWN_ERROR;

		// now pinning check
		List<Pin> pins = Pin.selectByUserId(userId);

		if (pins.isEmpty()) {
			Pin.insert(userId, contentId);
			result = PIN_ADDED;
		} else {
			if (pins.size() == 1) {
				Pin pin = pins.get(0);
				if (pin.contentId == contentId) {
					pin.delete();
					result = PIN_REMOVED;
				} else {
					pin.updateContentId(contentId);
					result = PIN_UPDATED;
				}
			} else {
				// １ユーザあたり複数pinは通常ありえないので、いちどまっさらにする。
				pins.forEach(Pin::delete);
				Pin.insert(userId, contentId);
				result = PIN_UPDATED;
			}
		}

		return result;
	}
}
