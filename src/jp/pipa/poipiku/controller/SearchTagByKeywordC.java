package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class SearchTagByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(cRequest.getParameter("KWD"));
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		if(m_strKeyword.isEmpty()) return bResult;
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			String strSqlFromWhere = "SELECT tag_txt "
					+ "FROM tags_0000 "
					+ "WHERE tag_txt &@~ ? GROUP BY tag_txt ";
			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(tag_txt) FROM (" + strSqlFromWhere + ") as T";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, m_strKeyword);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = strSqlFromWhere
					+ "ORDER BY COUNT(tag_txt) DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, m_strKeyword);
			cState.setInt(2, m_nPage*SELECT_MAX_GALLERY);
			cState.setInt(3, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CTag tag = new CTag(cResSet);
				m_vContentList.add(tag);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}

}
