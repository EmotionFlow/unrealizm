package jp.pipa.poipiku.controller.upcontents.v1;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.util.Util;

public class UpdateCParam extends UpCParam{
	public int m_nContentId = -1;
	public boolean m_bNotRecently = false;
	public boolean m_bDeleteTweet = false;

	public int GetParam(HttpServletRequest request){
		try {
			super.GetParams(request);
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_bNotRecently	= Util.toBoolean(request.getParameter("REC"));
			m_bDeleteTweet	= Util.toBoolean(request.getParameter("DELTW"));
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
	}
}
