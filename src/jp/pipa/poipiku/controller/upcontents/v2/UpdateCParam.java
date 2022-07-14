package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateCParam extends UpCParam {
	public int contentId = -1;
	public boolean isNotRecently = false;
	public boolean isDeleteTweet = false;

	public int GetParam(HttpServletRequest request){
		try {
			super.GetParams(request);
			contentId = Util.toInt(request.getParameter("IID"));
			isNotRecently = Util.toBoolean(request.getParameter("REC"));
			isDeleteTweet = Util.toBoolean(request.getParameter("DELTW"));
		} catch(Exception e) {
			return super.ErrorOccurred(e);
		}
		return 0;
	}
}
