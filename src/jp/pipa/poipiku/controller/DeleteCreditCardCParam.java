package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;

import javax.servlet.http.HttpServletRequest;

public class DeleteCreditCardCParam {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(cRequest.getParameter("ID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}