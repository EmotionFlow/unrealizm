package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class PopularIllustListC {
	public int m_nAccessUserId = -1;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


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

			StringBuilder sb = new StringBuilder();
			sb.append(" FROM contents_0000")
			.append(" INNER JOIN rank_contents_total ON contents_0000.content_id=rank_contents_total.content_id")
			.append(" WHERE open_id<>2");
			if(cCheckLogin.m_bLogin){
				sb.append(" AND safe_filter<=?")
				.append(" AND rank_contents_total.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?)")
				.append(" AND rank_contents_total.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)");
			}
			final String strSqlFromWhere = new String(sb);

			// POPULAR
			if(!bContentOnly) {
				strSql = "SELECT count(*)" + strSqlFromWhere;
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				if(cCheckLogin.m_bLogin){
					cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
					cState.setInt(idx++, cCheckLogin.m_nUserId);
					cState.setInt(idx++, cCheckLogin.m_nUserId);
				}
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

			//strSql = "SELECT * FROM vw_rank_contents_total WHERE user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			//strSql = "SELECT contents_0000.* FROM contents_0000 INNER JOIN rank_contents_total ON contents_0000.content_id=rank_contents_total.content_id WHERE rank_contents_total.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND rank_contents_total.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND open_id<>2 AND safe_filter<=? ORDER BY rank_contents_total.add_date DESC NULLS LAST OFFSET ? LIMIT ?";
			strSql = "SELECT contents_0000.*" + strSqlFromWhere + " ORDER BY rank_contents_total.add_date DESC NULLS LAST OFFSET ? LIMIT ?";

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			if(cCheckLogin.m_bLogin){
				cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
			}
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
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;
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
