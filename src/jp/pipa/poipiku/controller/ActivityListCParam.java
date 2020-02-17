package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;

public class ActivityListCParam {
	public int m_nUserId = -1;
	public int m_nMode = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nMode = Common.ToInt(cRequest.getParameter("MOD"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}
