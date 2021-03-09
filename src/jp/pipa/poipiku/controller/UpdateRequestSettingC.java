package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.RequestCreator;

public class UpdateRequestSettingC {
    public UpdateRequestSettingC(){}

    public boolean GetResults(UpdateRequestSettingCParam param, CheckLogin checkLogin) {
    	boolean result = false;
    	RequestCreator requestCreator = new RequestCreator(checkLogin);
    	if (requestCreator.userId < 0) {
    		return false;
	    }

    	String paramValue = param.value;
    	switch (param.attribute) {
		    case "RequestEnabled":
		    	requestCreator.updateStatus(
		    			Integer.parseInt(paramValue)==1?RequestCreator.Status.Enabled:RequestCreator.Status.Disabled
			    );
		    	break;

		    default:
			    result = false;
	    }




		return result;
	}
}
