package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

public final class UploadTextCParam extends UpCParam {
	public String m_strTextBody = "";
	public boolean m_bNotRecently = false;

	public int GetParam(HttpServletRequest request) {
		try {
			super.GetParams(request);
			m_strTextBody = Common.TrimBlankLines(request.getParameter("BDY"));
			m_bNotRecently = Util.toBoolean(request.getParameter("REC"));
		} catch (Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
	}
}