package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateCParam extends UpCParam {
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
