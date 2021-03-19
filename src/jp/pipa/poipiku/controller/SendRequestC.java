package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SendRequestC {
	public int clientUserId = -1;
	public int creatorUserId = -1;
	public int mediaId = -1;
	public String requestText = "";
	public int requestCategory = -1;
	public int amount = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			clientUserId = Util.toInt(request.getParameter("CLIENT"));
			creatorUserId = Util.toInt(request.getParameter("CREATOR"));
			mediaId = Util.toInt(request.getParameter("MEDIA"));
			requestText = Common.TrimAll(request.getParameter("TEXT"));
			requestCategory = Util.toInt(request.getParameter("CATEGORY"));
			amount = Util.toInt(request.getParameter("AMOUNT"));
		} catch(Exception e) {
			clientUserId = -1;
			creatorUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != clientUserId) {
			return -1;
		}
		Request request = new Request();
		request.clientUserId = clientUserId;
		request.creatorUserId = creatorUserId;
		request.mediaId = mediaId;
		request.requestText = requestText;
		request.requestCategory = requestCategory;
		request.amount = amount;
		int requestResult = request.insert();
		if (requestResult == 0) {
			RequestNotifier.notifyRequestReceived(request);
		}
		return requestResult;
	}
}
