package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.Common;

import javax.servlet.http.HttpServletRequest;

public class RequestExchangeCheerPointCParam {
	public int m_nUserId = -1;
	public String m_strFinancialCode = "";
	public String m_strFinancialName = "";
	public String m_strFinancialSubCode = "";
	public int m_nAccountType = -1;
	public String m_strAccountCode = "";
	public String m_strAccountName = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId				= Common.ToInt(cRequest.getParameter("ID"));
			m_strFinancialCode		= Common.TrimAll(cRequest.getParameter("FCD"));
			m_strFinancialName		= Common.TrimAll(cRequest.getParameter("FNM"));
			m_strFinancialSubCode	= Common.TrimAll(cRequest.getParameter("FSUBCD"));
			m_nAccountType			= Common.ToInt(cRequest.getParameter("ACTYPE"));
			m_strAccountCode 		= Common.TrimAll(cRequest.getParameter("ACCD"));
			m_strAccountName 		= Common.TrimAll(cRequest.getParameter("ACNM"));
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
		}
	}

	public String toString(){
		return String.format("%d, %s, %s, %s, %d, %s, %s",
				m_nUserId, m_strFinancialCode, m_strFinancialName,
				m_strFinancialSubCode, m_nAccountType, m_strAccountCode,
				m_strAccountName);
	}

}