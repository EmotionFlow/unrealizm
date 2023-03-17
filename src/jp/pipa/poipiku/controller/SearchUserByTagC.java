package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class SearchUserByTagC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_strKeyword	= Common.TrimAll(cRequest.getParameter("KWD"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CUser> contentList = new ArrayList<CUser>();
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
		int idx = 1;

		if(m_strKeyword.isEmpty()) return bResult;
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT COUNT(*) FROM users_0000 WHERE user_id IN(SELECT user_id FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?)";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setString(idx++, m_strKeyword);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nSafeFilter);
				/*
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				*/
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = "SELECT * FROM users_0000 WHERE user_id IN(SELECT user_id FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?) OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setString(idx++, m_strKeyword);
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setInt(idx++, checkLogin.m_nUserId);
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
			/*
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			*/
			cState.setInt(idx++, SELECT_MAX_GALLERY*m_nPage);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				contentList.add(new CUser(cResSet));
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
