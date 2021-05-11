package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.PassportSubscription;

public class CancelPassportC {
	public int m_nErrCode = PassportSubscription.ErrorKind.Unknown.getCode();

	public boolean getResults(CheckLogin checkLogin, CancelPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!checkLogin.m_bLogin) return false;
		if(checkLogin.m_bLogin && (cParam.m_nUserId != checkLogin.m_nUserId)) return false;

		PassportSubscription cPassport = new PassportSubscription(checkLogin);
		boolean result = cPassport.cancel();
		m_nErrCode = cPassport.errorKind.getCode();
		return result;
	}
}
