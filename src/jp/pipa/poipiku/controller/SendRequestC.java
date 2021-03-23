package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class SendRequestC {
	public int clientUserId = -1;
	public int creatorUserId = -1;
	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int amount = -1;
	public int agentId = -1;
	public String ipAddress = "";
	public String agentToken = "";
	public String cardExpire = "";
	public String cardSecurityCode = "";
	public String userAgent = "";


	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			clientUserId = Util.toInt(request.getParameter("CLIENT"));
			creatorUserId = Util.toInt(request.getParameter("CREATOR"));
			mediaId = Util.toInt(request.getParameter("MEDIA"));
			requestText = Common.TrimAll(request.getParameter("TEXT"));
			requestCategory = Util.toInt(request.getParameter("CATEGORY"));
			amount = Util.toInt(request.getParameter("AMOUNT"));
			agentId = Util.toInt(request.getParameter("AID"));
			agentToken = Util.toString(request.getParameter("TKN"));
			cardExpire	= Util.toString(request.getParameter("EXP"));
			cardSecurityCode	= Util.toString(request.getParameter("SEC"));
			userAgent  = request.getHeader("user-agent");
			ipAddress = request.getRemoteAddr();
		} catch(Exception e) {
			clientUserId = -1;
			creatorUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != clientUserId) {
			return -99;
		}
		Request poipikuRequest = new Request();
		poipikuRequest.clientUserId = clientUserId;
		poipikuRequest.creatorUserId = creatorUserId;
		poipikuRequest.mediaId = mediaId;
		poipikuRequest.requestText = requestText;
		poipikuRequest.requestCategory = requestCategory;
		poipikuRequest.amount = amount;

		boolean sendResult = poipikuRequest.send(
				agentToken,
				cardExpire,
				cardSecurityCode,
				userAgent
		);

		if (sendResult) {
			RequestNotifier.notifyRequestReceived(poipikuRequest);
		} else {
			return poipikuRequest.errorKind.getCode();
		}

		return 0;
	}
}
