package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;

public class UploadFileTweetCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOptImage = 1;
	public int m_nOptDeleteTweet = 0;

	public int GetParam(HttpServletRequest request) {
		try {
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_nOptImage		= Common.ToIntN(request.getParameter("IMG"), 0, 1);
			m_nOptDeleteTweet	= Common.ToIntN(request.getParameter("DELTW"), 0, 1);
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}
