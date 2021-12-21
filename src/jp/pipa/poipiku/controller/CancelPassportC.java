package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;
import jp.pipa.poipiku.PassportSubscription;
import jp.pipa.poipiku.util.Log;

public final class CancelPassportC {
	public int m_nErrCode = PassportSubscription.ErrorKind.Unknown.getCode();

	public boolean getResults(CheckLogin checkLogin, CancelPassportCParam cParam) {
		Log.d("enter");
		if(cParam.m_nUserId<0){
			Log.d("cParam.m_nUserId<0");
			return false;
		}
		if(!checkLogin.m_bLogin){
			Log.d("!checkLogin.m_bLogin");
			return false;
		}
		if(cParam.m_nUserId != checkLogin.m_nUserId){
			Log.d("cParam.m_nUserId != checkLogin.m_nUserId");
			return false;
		}

		PassportSubscription subscription = new PassportSubscription(checkLogin);
		boolean result = subscription.cancel();
		m_nErrCode = subscription.errorKind.getCode();

		if (result) {
			Passport passport = new Passport(checkLogin);
			passport.cancelSubscription();
		}

		/* users_0000は月末までそのまま。月初にスクリプトで更新 */
		/* 25日以降に解約した場合、イプシロン上では翌月課金される状態になっているが、月初にスクリプトで金額を0円に更新している */

		return result;
	}
}
