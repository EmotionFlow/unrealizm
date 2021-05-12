package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;
import jp.pipa.poipiku.PassportSubscription;

public final class CancelPassportC {
	public int m_nErrCode = PassportSubscription.ErrorKind.Unknown.getCode();

	public boolean getResults(CheckLogin checkLogin, CancelPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!checkLogin.m_bLogin) return false;
		if(checkLogin.m_bLogin && (cParam.m_nUserId != checkLogin.m_nUserId)) return false;

		PassportSubscription subscription = new PassportSubscription(checkLogin);
		boolean result = subscription.cancel();
		m_nErrCode = subscription.errorKind.getCode();

		Passport passport = new Passport(checkLogin);
		passport.cancelSubscription();

		/* users_0000は月末までそのまま。月初にスクリプトで更新 */

		return result;
	}
}
