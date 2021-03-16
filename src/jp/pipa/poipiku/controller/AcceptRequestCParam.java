package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class AcceptRequestCParam {
	public int requestId = -1;

	public void GetParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			requestId   = Util.toInt(request.getParameter("ID"));
		} catch (Exception e) {
			requestId = -1;
		}
	}
}
