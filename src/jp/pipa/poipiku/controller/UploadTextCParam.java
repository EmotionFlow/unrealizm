package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

public final class UploadTextCParam extends UpCParam {
	public String m_strTextBody = "";
	public boolean m_bNotRecently = false;
	public String title = "";
	public int novelDirection = 0;

	public int GetParam(HttpServletRequest request) {
		try {
			super.GetParams(request);
			m_strTextBody = Util.deleteInvalidChar(Common.TrimHeadBlankLines(request.getParameter("BDY")));
			m_bNotRecently = Util.toBoolean(request.getParameter("REC"));
			title = Util.deleteInvalidChar(Util.subStrNum(request.getParameter("TIT"), 100));
			novelDirection = Util.toIntN(request.getParameter("DIR"), 0, 1);
		} catch (Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
	}
}