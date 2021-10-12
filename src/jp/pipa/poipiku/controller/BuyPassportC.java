package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;
import jp.pipa.poipiku.PassportSubscription;
import jp.pipa.poipiku.util.Log;

public final class BuyPassportC {
	public int errorCode = PassportSubscription.ErrorKind.Unknown.getCode();

	public boolean getResults(CheckLogin checkLogin, BuyPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!checkLogin.m_bLogin) return false;
		if(cParam.m_nUserId != checkLogin.m_nUserId) return false;

		PassportSubscription subscription = new PassportSubscription(checkLogin);

		boolean exitsBuyHistory = subscription.existsBuyHistory();

		boolean result;
		result = subscription.buy(
			cParam.m_nPassportId,
			cParam.m_strAgentToken,
			cParam.m_strCardExpire,
			cParam.m_strCardSecurityCode,
			cParam.m_strUserAgent
		);

		if (result) {
			Passport passport = new Passport(checkLogin);
			if (!passport.exists) {
				passport.courseId = 1;
				result = passport.insert();
			}
			if (result) {
				result = passport.activate();
			} else {
				Log.d("passport.insert() failed");
			}
 		} else {
			Log.d("subscription.buy() failed");
			errorCode = subscription.errorKind.getCode();
		}

		return result;
	}
}