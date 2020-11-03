package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;

public class DeleteCreditCardCParam {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId			= Util.toInt(cRequest.getParameter("ID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}