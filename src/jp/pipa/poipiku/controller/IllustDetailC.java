package jp.pipa.poipiku.controller;

import java.sql.*;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustDetailC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nAppendId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
			m_nAppendId		= Common.ToInt(cRequest.getParameter("AD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}


	public CContent m_cContent = new CContent();
	public boolean getResults(CheckLogin cCheckLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			// content main
			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent.m_strFileName = cResSet.getString("file_name");
				bRtn = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			if(m_nAppendId>0 && bRtn) {
				bRtn = false;
				strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? AND append_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cState.setInt(2, m_nAppendId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					m_cContent.m_strFileName = cResSet.getString("file_name");
					bRtn = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
