package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.RequestCreator;
import jp.pipa.poipiku.RequestNotifier;
import jp.pipa.poipiku.ResourceBundleControl;

public final class UpdateRequestSettingC extends Controller{
    public UpdateRequestSettingC(){}

    public boolean GetResults(final UpdateRequestSettingCParam param, final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
	    final RequestCreator requestCreator = new RequestCreator(checkLogin);
    	if (requestCreator.userId < 0) {
    		return false;
	    }

    	final String paramValue = param.value;
    	boolean updateResult;
    	switch (param.attribute) {
		    case "RequestEnabled":
			    updateResult = requestCreator.updateStatus(
					    paramValue.equals("1") ? RequestCreator.Status.Enabled : RequestCreator.Status.Disabled
			    );
		    	if (requestCreator.status == RequestCreator.Status.Enabled) {
				    RequestNotifier.notifyRequestEnabled(checkLogin, _TEX);
			    }
		    	break;
		    case "RequestMedia":
		    	String[] allowMedias = paramValue.split(",");
			    updateResult = requestCreator.updateAllowMedia(
					    allowMedias[0].equals("1"),
					    allowMedias[1].equals("1")
			    );
			    break;
		    case "AllowSensitive":
			    updateResult = requestCreator.updateAllowSensitive(
		    			paramValue.equals("1")
			    );
			    break;
		    case "ReturnPeriod":
			    updateResult = requestCreator.updateReturnPeriod(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "DeliveryPeriod":
			    updateResult = requestCreator.updateDeliveryPeriod(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "AmountLeftToMe":
			    updateResult = requestCreator.updateAmountLeftToMe(
		    			Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "AmountMinimum":
			    updateResult = requestCreator.updateAmountMinimum(
					    Integer.parseInt(paramValue, 10)
			    );
			    break;
		    case "CommercialTransactionLaw":
			    updateResult = requestCreator.updateCommercialTransactionLaw(
		    			paramValue
			    );
			    break;
		    default:
			    updateResult = false;
	    }

	    boolean result;
	    if (!updateResult) {
	    	result = false;
	    	errorKind = ErrorKind.Unknown;
	    } else {
	    	result = true;
	    	errorKind = ErrorKind.None;
	    }
		return result;
	}
}
