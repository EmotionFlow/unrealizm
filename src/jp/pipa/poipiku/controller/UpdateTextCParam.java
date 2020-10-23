package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

public class UpdateTextCParam extends UpCParam{
	public String m_strTextBody = "";
	public boolean m_bNotRecently = false;
	public int m_nContentId = -1;
	public boolean m_bDeleteTweet = false;

	public int GetParam(HttpServletRequest request){
		try {
			super.GetParams(request);
			m_strTextBody	= Common.TrimAll(request.getParameter("BDY"));
			m_bNotRecently	= Util.toBoolean(request.getParameter("REC"));
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_bDeleteTweet	= Util.toBoolean(request.getParameter("DELTW"));
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
	}
}
