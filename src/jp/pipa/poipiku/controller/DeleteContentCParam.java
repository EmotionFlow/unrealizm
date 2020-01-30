package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class DeleteContentCParam {
	public int m_nContentId = -1;
	public int m_nUserId = -1;
	public int m_nDeleteTweet = 0;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(cRequest.getParameter("UID"));
			m_nContentId		= Common.ToInt(cRequest.getParameter("CID"));
			m_nDeleteTweet		= Common.ToIntN(cRequest.getParameter("DELTW"), 0, 1);
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}
}