package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;

public class CancelPassportC {
	public int m_nErrCode = Passport.ERR_NONE;

	public boolean getResults(CheckLogin cCheckLogin, BuyPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!cCheckLogin.m_bLogin) return false;
		if(cCheckLogin.m_bLogin && (cParam.m_nUserId != cCheckLogin.m_nUserId)) return false;

		Passport cPassport = new Passport(cCheckLogin);

		boolean result = cPassport.cancel();

		m_nErrCode = cParam.m_nErrCode;
		return result;
	}
}