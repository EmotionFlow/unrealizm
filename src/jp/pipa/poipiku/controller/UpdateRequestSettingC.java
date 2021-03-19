package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.RequestCreator;
import jp.pipa.poipiku.RequestNotifier;
import jp.pipa.poipiku.ResourceBundleControl;

public class UpdateRequestSettingC {
    public UpdateRequestSettingC(){}

    public boolean GetResults(UpdateRequestSettingCParam param, CheckLogin checkLogin, ResourceBundleControl _TEX) {
    	boolean result = false;
    	RequestCreator requestCreator = new RequestCreator(checkLogin);
    	if (requestCreator.userId < 0) {
    		return false;
	    }

    	final String paramValue = param.value;
    	switch (param.attribute) {
		    case "RequestEnabled":
		    	requestCreator.updateStatus(
					    paramValue.equals("1") ? RequestCreator.Status.Enabled : RequestCreator.Status.Disabled
			    );
		    	if (requestCreator.status == RequestCreator.Status.Enabled) {
				    RequestNotifier.notifyRequestEnabled(checkLogin, _TEX);
			    }
		    	break;
		    case "RequestMedia":
		    	String[] allowMedias = paramValue.split(",");
		    	requestCreator.updateAllowMedia(
					    allowMedias[0].equals("1"),
					    allowMedias[1].equals("1")
			    );
			    break;
		    case "AllowSensitive":
		    	requestCreator.updateAllowSensitive(
		    			paramValue.equals("1")
			    );
			    break;
		    case "ReturnPeriod":
		    	requestCreator.updateReturnPeriod(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "DeliveryPeriod":
		    	requestCreator.updateDeliveryPeriod(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "AmountLeftToMe":
		    	requestCreator.updateAmountLeftToMe(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "AmountMinimum":
			    requestCreator.updateAmountMinimum(
					    Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "CommercialTransactionLaw":
		    	requestCreator.updateCommercialTransactionLaw(
		    			paramValue
			    );
			    break;
		    default:
			    result = false;
	    }

		return result;
	}
}
