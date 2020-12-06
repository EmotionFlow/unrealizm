package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;

public class CancelPassportC {
	public int m_nErrCode = Passport.ERR_NONE;

	public boolean getResults(CheckLogin checkLogin, CancelPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!checkLogin.m_bLogin) return false;
		if(checkLogin.m_bLogin && (cParam.m_nUserId != checkLogin.m_nUserId)) return false;

		Passport cPassport = new Passport(checkLogin);

		boolean result = cPassport.cancel();

		m_nErrCode = cParam.m_nErrCode;
		return result;
	}
}