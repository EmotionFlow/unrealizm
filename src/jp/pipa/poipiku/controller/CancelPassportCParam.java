package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class CancelPassportCParam {
	public int m_nUserId = -1;
	public int m_nPassportId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPassportId   = Util.toInt(cRequest.getParameter("PID"));
			m_nUserId		= Util.toInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}