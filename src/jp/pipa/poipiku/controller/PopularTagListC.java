package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class PopularTagListC {
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 50;
	public int SELECT_MAX_SAMPLE_GALLERY = 10;
	public int SELECT_SAMPLE_GALLERY = 3;
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
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// TAG LIST
			/*
			CTag cPriprityTag = new CTag();
			cPriprityTag = new CTag();
			cPriprityTag.m_strTagTxt = "カラパレコスメ";
			m_vContentListWeekly.add(cPriprityTag);

			cPriprityTag = new CTag();
			cPriprityTag.m_strTagTxt = "お題ルーレット";
			m_vContentListWeekly.add(cPriprityTag);
			*/

			//strSql = "select tag_txt FROM vw_rank_tag_weekly WHERE tag_txt NOT IN('カラパレコスメ', 'お題ルーレット') order by rank desc offset ? limit ?";
			//strSql = "select tag_txt FROM vw_rank_tag_weekly order by rank desc offset ? limit ?";
			strSql = "select tag_txt FROM vw_rank_tag_daily order by rank desc offset ? limit ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nPage*SELECT_MAX_GALLERY);
			cState.setInt(2, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentListWeekly.add(new CTag(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			String strMuteKeyword = "";
			String strCondMute = "";

			// MUTE KEYWORD
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strSql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					strMuteKeyword = Util.toString(cResSet.getString(1)).trim();
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// WEEKLY SAMPLE
			StringBuilder sb = new StringBuilder();
			sb.append("SELECT * FROM contents_0000 WHERE open_id<>2 AND content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=? AND tag_type=1) ");
			if(cCheckLogin.m_bLogin){
				sb.append("AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ");
			}
			if(!strCondMute.isEmpty()){
				sb.append(strCondMute);
			}
			sb.append("AND safe_filter<=? ");
			sb.append("ORDER BY content_id DESC LIMIT ?");
			strSql = new String(sb);
			cState = cConn.prepareStatement(strSql);
			for(int nCnt=0; nCnt<m_vContentListWeekly.size() && nCnt<SELECT_MAX_SAMPLE_GALLERY; nCnt++) {
				CTag cTag = m_vContentListWeekly.get(nCnt);
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				cState.setString(idx++, cTag.m_strTagTxt);
				if(cCheckLogin.m_bLogin){
					cState.setInt(idx++, cCheckLogin.m_nUserId);
					cState.setInt(idx++, cCheckLogin.m_nUserId);
				}
				if(!strCondMute.isEmpty()){
					cState.setString(idx++, strMuteKeyword);
				}
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
				cState.setInt(idx++, SELECT_SAMPLE_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent(cResSet);
					CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
					cContent.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
					cContent.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
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
