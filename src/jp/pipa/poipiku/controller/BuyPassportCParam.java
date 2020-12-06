package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class BuyPassportCParam {
	public final int ERR_NONE = 0;
	public final int ERR_RETRY = -10;
	public final int ERR_INQUIRY = -20;
	public final int ERR_CARD_AUTH = -30;
	public final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public int m_nPassportId = -1;
	public int m_nAgentId = -1;
	public String m_strAgentToken = "";
	public String m_strIpAddress = "";
	public String m_strCardExpire = "";
	public String m_strCardSecurityCode = "";
	public int m_nErrCode = ERR_UNKNOWN;
	public String m_strUserAgent = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPassportId   = Util.toInt(cRequest.getParameter("PID"));
			m_nUserId		= Util.toInt(cRequest.getParameter("UID"));
			m_nAgentId		= Util.toInt(cRequest.getParameter("AID"));
			m_strIpAddress	= cRequest.getRemoteAddr();
			m_strAgentToken = Util.toString(cRequest.getParameter("TKN"));
			m_strCardExpire	= Util.toString(cRequest.getParameter("EXP"));
			m_strCardSecurityCode	= Util.toString(cRequest.getParameter("SEC"));
			m_strUserAgent  = cRequest.getHeader("user-agent");
			m_nErrCode = ERR_NONE;
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}