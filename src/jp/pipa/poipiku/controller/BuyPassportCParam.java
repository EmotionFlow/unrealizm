package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class BuyPassportCParam {
	public int m_nUserId = -1;
	public int m_nPassportId = -1;
	public int m_nAgentId = -1;
	public String m_strAgentToken = "";
	public String m_strIpAddress = "";
	public String m_strCardExpire = "";
	public String m_strCardSecurityCode = "";
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
			m_strUserAgent  = cRequest.getHeader("user-agent");
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}