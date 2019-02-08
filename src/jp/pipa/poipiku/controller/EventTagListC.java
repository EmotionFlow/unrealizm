package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class EventTagListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 50;
	public int SELECT_MAX_SAMPLE_GALLERY = 0;
	public int SELECT_SAMPLE_GALLERY = 0;
	//public ArrayList<CTag> m_vContentList = new ArrayList<CTag>();
	public ArrayList<CTag> m_vContentListWeekly = new ArrayList<CTag>();
	//public ArrayList<ArrayList<CContent>> m_vContentSamplpeList = new ArrayList<ArrayList<CContent>>();
	public ArrayList<ArrayList<CContent>> m_vContentSamplpeListWeekly = new ArrayList<ArrayList<CContent>>();


	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// TAG LIST
			strSql = "select tag_txt FROM vw_event_tag ORDER BY first_date DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nPage*SELECT_MAX_GALLERY);
			cState.setInt(2, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentListWeekly.add(new CTag(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			/*
			strSql = "select tag_txt FROM vw_rank_tag_daily order by rank desc offset ? limit ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nPage*SELECT_MAX_GALLERY);
			cState.setInt(2, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(new CTag(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			*/


			/*
			// MUTE KEYWORD
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

			// WEEKLY SAMPLE
			strSql = "SELECT * FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? ORDER BY content_id DESC LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			for(int nCnt=0; nCnt<m_vContentListWeekly.size() && nCnt<SELECT_MAX_SAMPLE_GALLERY; nCnt++) {
				CTag cTag = m_vContentListWeekly.get(nCnt);
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				cState.setString(idx++, cTag.m_strTagTxt);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
				/*
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				*/
				cState.setInt(idx++, SELECT_SAMPLE_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					m_vContentList.add(cContent);
				}
				cResSet.close();cResSet=null;
				m_vContentSamplpeListWeekly.add(m_vContentList);
			}
			// DAILY SAMPLE
			/*
			for(CTag cTag : m_vContentList) {
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				cState.setString(idx++, cTag.m_strTagTxt);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				cState.setInt(idx++, SELECT_SAMPLE_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					m_vContentList.add(cContent);
				}
				cResSet.close();cResSet=null;
				m_vContentSamplpeList.add(m_vContentList);
			}
			cState.close();cState=null;
			*/

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
