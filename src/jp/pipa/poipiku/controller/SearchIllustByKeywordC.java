package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class SearchIllustByKeywordC {
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
			m_strKeyword = Common.TrimAll(cRequest.getParameter("KWD"));
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public boolean m_bFollowing = false;
	public String m_strRepFileName = "";

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
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

			// Check Following
			strSql = "SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setString(idx++, m_strKeyword);
			cState.setInt(idx++, Common.FOVO_KEYWORD_TYPE_SEARCH);
			cResSet = cState.executeQuery();
			m_bFollowing = (cResSet.next());
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			/*
			String strMuteKeyword = "";
			String strCond = "";
			if(cCheckLogin.m_bLogin) {
				strSql = "SELECT mute_keyword FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					strMuteKeyword = Common.ToString(cResSet.getString(1)).trim();
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(!strMuteKeyword.isEmpty()) {
					strCond = "AND description &@~ ?";
				}
			}
			*/


			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT count(*) FROM contents_0000 WHERE open_id<>2 AND description &@~ ? AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setString(idx++, m_strKeyword);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
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

			strSql = "SELECT * FROM contents_0000 WHERE open_id<>2 AND description &@~ ? AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setString(idx++, m_strKeyword);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
			/*
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			*/
			cState.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				m_vContentList.add(cContent);
				if(!bContentOnly && m_strRepFileName.isEmpty() && cContent.m_nPublishId==Common.PUBLISH_ID_ALL) {
					m_strRepFileName = cContent.m_strFileName;
				}
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
