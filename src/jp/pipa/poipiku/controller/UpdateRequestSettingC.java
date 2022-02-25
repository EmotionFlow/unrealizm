package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.notify.RequestNotifier;
import jp.pipa.poipiku.util.CTweet;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public final class UpdateRequestSettingC extends Controller{
    public UpdateRequestSettingC(){}

    private boolean judgementRequestEnabled(final CheckLogin checkLogin) {
	    Connection connection = null;
	    PreparedStatement statement = null;
	    ResultSet resultSet = null;
	    String strSql = "";
	    try {
		    connection = DatabaseUtil.dataSource.getConnection();

		    // 公開コンテンツが0
		    strSql = "SELECT content_id FROM contents_0000 WHERE user_id=? AND open_id<>2";
		    statement = connection.prepareStatement(strSql);
		    statement.setInt(1,checkLogin.m_nUserId);
		    resultSet = statement.executeQuery();
		    if(!resultSet.next()){
		    	return false;
		    }
		    resultSet.close();
		    statement.close();

		    // メアド認証がされていない
		    strSql = "SELECT user_id FROM users_0000 WHERE user_id=? AND email LIKE '%@%'";
		    statement = connection.prepareStatement(strSql);
		    statement.setInt(1,checkLogin.m_nUserId);
		    resultSet = statement.executeQuery();
		    if(!resultSet.next()){
			    return false;
		    }
		    resultSet.close();
		    statement.close();

		    // 登録が最近すぎる
		    strSql = "SELECT MAX(user_id) FROM users_0000";
		    statement = connection.prepareStatement(strSql);
		    resultSet = statement.executeQuery();
		    if(resultSet.next()){
			    if ( resultSet.getInt(1) - checkLogin.m_nUserId < 10){
			    	return false;
			    }
		    } else {
		    	return false;
		    }
		    resultSet.close();
		    statement.close();

		    // 連携しているTwitterアカウントの登録日が１４日以内
		    CTweet cTweet = new CTweet();
		    cTweet.GetResults(checkLogin.m_nUserId);
		    DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		    Date createdAt = cTweet.getCreatedAt();
		    Date limitDate = new Date(System.currentTimeMillis() - 1000L * 60 * 60 * 24 * 14);
		    Log.d(dateFormat.format(createdAt));
		    Log.d(dateFormat.format(limitDate));
		    if (createdAt.after(limitDate)) {
		    	Log.d("連携しているTwitterアカウントの登録日が１４日以内");
		    	return false;
		    }
	    } catch(Exception e) {
		    Log.d(strSql);
		    e.printStackTrace();
		    return false;
	    } finally {
		    try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
		    try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
		    try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
	    }

    	return true;
    }

    public boolean GetResults(final UpdateRequestSettingCParam param, final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
	    final RequestCreator requestCreator = new RequestCreator(checkLogin);
    	if (requestCreator.userId < 0) {
    		return false;
	    }

    	final String paramValue = param.value;
    	boolean updateResult;
    	switch (param.attribute) {
		    case "RequestEnabled":
		    	if (paramValue.equals("1") && !judgementRequestEnabled(checkLogin)) {
				    errorKind = ErrorKind.JudgeFailure;
				    return false;
			    }

			    updateResult = requestCreator.updateStatus(
					    paramValue.equals("1") ? RequestCreator.Status.Enabled : RequestCreator.Status.Disabled
			    );
		    	if (requestCreator.status == RequestCreator.Status.Enabled) {
				    RequestNotifier notifier = new RequestNotifier();
				    notifier.notifyRequestEnabled(checkLogin, _TEX);
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
		    case "AllowAnonymous":
			    updateResult = requestCreator.updateAllowAnonymous(
					    paramValue.equals("1")
			    );
			    break;
		    case "AllowFreeRequest":
			    updateResult = requestCreator.updateAllowFreeRequest(
					    paramValue.equals("1")
			    );
			    break;
		    case "AllowPaidRequest":
			    updateResult = requestCreator.updateAllowPaidRequest(
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
		    case "Profile":
			    updateResult = requestCreator.updateProfile(
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
