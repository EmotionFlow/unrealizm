package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateFollowCParam {
	public int m_nFollowedUserId = -1;
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nFollowedUserId	= Util.toInt(cRequest.getParameter("IID"));
			m_nUserId			= Util.toInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			m_nFollowedUserId = -1;
			m_nUserId = -1;
		}
	}
}