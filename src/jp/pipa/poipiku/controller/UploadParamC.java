package jp.pipa.poipiku.controller;

import javax.servlet.http.HttpServletRequest;

public class UploadParamC extends UpParamC{
    public int GetParam(HttpServletRequest request){
        try {
			super.GetParams(request);
		} catch(Exception e) {
			return super.ErrorOccured(e);
		}
		return 0;
    }
}
