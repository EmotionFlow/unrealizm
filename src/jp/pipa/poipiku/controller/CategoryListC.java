package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class CategoryListC {
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 12;
	public int SELECT_SAMPLE_GALLERY = 5;
	public ArrayList<Integer> m_vContentList = new ArrayList<Integer>();
	public ArrayList<ArrayList<CContent>> m_vContentSamplpeList = new ArrayList<ArrayList<CContent>>();

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

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			// CATEGORY LIST
			strSql = "SELECT category_id FROM vw_rank_category_weekly ORDER BY rank DESC LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(cResSet.getInt("category_id"));
			}
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


			// CATEGORY
			strSql = "SELECT * FROM contents_0000 WHERE open_id<>2 AND category_id=? AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=? ORDER BY content_id DESC LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			for(int nCategoryId : m_vContentList) {
				ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
				idx = 1;
				cState.setInt(idx++, nCategoryId);
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
				m_vContentSamplpeList.add(m_vContentList);
			}
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
