package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.CreditCard;
import jp.pipa.poipiku.settlement.Agent;


public final class CheckCreditCardC {
	private int verify(int nUserId) {
		int nResult = -1;
		CreditCard creditCard = new CreditCard(nUserId, Agent.EPSILON);
		creditCard.selectByUserIdAgentId();

		if (!creditCard.isExist) {
			nResult = 0;
		} else {
			if (creditCard.isExpired(1) || creditCard.isInvalid) {
				creditCard.delete();
				nResult = 0;
			} else {
				nResult = 1;
			}
		}
		return nResult;
	}

	public int getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin){return -1;}
		return verify(checkLogin.m_nUserId);
	}
}
