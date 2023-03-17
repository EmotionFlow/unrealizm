package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class ChangeCreditCardInfoC extends Controller {
	public String agentUserId = "";
	public String agentToken = "";
	public String ipAddress = "";
	public String cardExpire = "";
	public String userAgent = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			agentUserId = Util.toString(request.getParameter("AID"));
			ipAddress = request.getRemoteAddr();
			agentToken = Util.toString(request.getParameter("TKN"));
			cardExpire = Util.toString(request.getParameter("EXP"));
			userAgent = request.getHeader("user-agent");
		} catch(Exception e) {
			agentUserId = "";
		}
	}

	public boolean getResults(final CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin  || agentUserId.isEmpty()) return false;
		PassportSubscription subscription = new PassportSubscription(checkLogin);
		return subscription.changeCreditCard(agentToken, cardExpire, userAgent);
	}
}
