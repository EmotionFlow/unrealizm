package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Passport;

public class BuyPassportC {
	public int m_nErrCode = Passport.ErrorKind.Unknown.getCode();

	public boolean getResults(CheckLogin checkLogin, BuyPassportCParam cParam) {
		if(cParam.m_nUserId<0) return false;
		if(!checkLogin.m_bLogin) return false;
		if(checkLogin.m_bLogin && (cParam.m_nUserId != checkLogin.m_nUserId)) return false;

		Passport passport = new Passport(checkLogin);

		boolean result = passport.buy(
				cParam.m_nPassportId,
				cParam.m_strAgentToken,
				cParam.m_strCardExpire,
				cParam.m_strCardSecurityCode,
				cParam.m_strUserAgent
		);

		m_nErrCode = passport.errorKind.getCode();
		return result;
	}
}