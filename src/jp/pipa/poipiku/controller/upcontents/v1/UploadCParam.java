package jp.pipa.poipiku.controller.upcontents.v1;

import javax.servlet.http.HttpServletRequest;

public class UploadCParam extends UpCParam {
    public int GetParam(HttpServletRequest request){
        try {
			super.GetParams(request);
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
    }
}
