package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

public class UploadFileTweetCParam {

	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int m_nOptImage = 1;
	public int m_nOptDeleteTweet = 0;

	public int GetParam(HttpServletRequest request) {
		try {
			m_nUserId		= Util.toInt(request.getParameter("UID"));
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_nOptImage		= Util.toIntN(request.getParameter("IMG"), 0, 1);
			m_nOptDeleteTweet	= Util.toIntN(request.getParameter("DELTW"), 0, 1);
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			return -99;
		}
		return 0;
	}
}
