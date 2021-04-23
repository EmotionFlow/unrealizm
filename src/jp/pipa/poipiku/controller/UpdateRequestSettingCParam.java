package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public final class UpdateRequestSettingCParam {
	public int userId = -1;
	public String attribute = "";
	public String value = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			userId = Util.toInt(cRequest.getParameter("ID"));
			attribute = Common.TrimAll(cRequest.getParameter("ATTR"));
			value = Common.TrimAll(cRequest.getParameter("VAL"));
		} catch(Exception e) {
			e.printStackTrace();
			userId = -1;
		}
	}

	public String toString(){
		return String.format("%d, %s, %s",
				userId, attribute, value);
	}
}
