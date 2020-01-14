package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;

public class UpdateParamC extends UpParamC{
    public int m_nContentId = -1;

    public int GetParam(HttpServletRequest request){
        try {
			super.GetParams(request);
			m_nContentId		= Common.ToInt(request.getParameter("IID"));
			m_nOpenId			= Common.ToInt(request.getParameter("REC"));
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
    }
}
