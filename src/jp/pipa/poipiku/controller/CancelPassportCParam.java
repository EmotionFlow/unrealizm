package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class CancelPassportCParam {
	public final int ERR_NONE = 0;
	public final int ERR_RETRY = -10;
	public final int ERR_INQUIRY = -20;
	public final int ERR_CARD_AUTH = -30;
	public final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public int m_nPassportId = -1;
	public int m_nErrCode = ERR_UNKNOWN;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPassportId   = Util.toInt(cRequest.getParameter("PID"));
			m_nUserId		= Util.toInt(cRequest.getParameter("UID"));
			m_nErrCode = ERR_NONE;
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}