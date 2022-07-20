package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class UpdateTextCParam extends UpCParam {
	public String textBody = "";
	public boolean isNotRecently = false;
	public int contentId = -1;
	public boolean isDeleteTweet = false;
	public String title = "";
	public int novelDirection = 0;

	public int GetParam(HttpServletRequest request){
		try {
			super.GetParams(request);
			textBody = Util.deleteInvalidChar(Common.TrimHeadBlankLines(request.getParameter("BDY")));
			isNotRecently = Util.toBoolean(request.getParameter("REC"));
			contentId = Util.toInt(request.getParameter("IID"));
			isDeleteTweet = Util.toBoolean(request.getParameter("DELTW"));
			title = Util.deleteInvalidChar(Util.subStrNum(request.getParameter("TIT"), 100));
			novelDirection = Util.toIntN(request.getParameter("DIR"), 0, 1);
		} catch(Exception e) {
			return super.ErrorOccurred(e);
		}
		return 0;
	}
}