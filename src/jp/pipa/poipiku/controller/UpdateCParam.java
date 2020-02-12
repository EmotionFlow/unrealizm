package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;

public class UpdateCParam extends UpCParam{
	public int m_nContentId = -1;
	public boolean m_bNotRecently = false;
	public boolean m_bDeleteTweet = false;

    public int GetParam(HttpServletRequest request){
        try {
			super.GetParams(request);
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_bNotRecently	= Common.ToBoolean(request.getParameter("REC"));
			m_bDeleteTweet	= Common.ToBoolean(request.getParameter("DELTW"));
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
    }
}