package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class MyHomeC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nMode = 0;
	public int m_nStartId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Common.ToInt(cRequest.getParameter("VER"));
			m_nMode = Common.ToInt(cRequest.getParameter("MD"));
			m_nStartId = Common.ToInt(cRequest.getParameter("SD"));
			n_nUserId = Common.ToInt(cRequest.getParameter("ID"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = 60;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

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
			String strCondStart = (m_nStartId>0)?"AND content_id<?":"";


			// NEW ARRIVAL
			if(!bContentOnly) {
				//strSql = String.format("SELECT count(*) FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) AND safe_filter<=? %s", strCond);
				strSql = "SELECT count(*) FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) AND safe_filter<=?";
				cState = cConn.prepareStatement(strSql);
				idx = 1;
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


				// User contents total number
				idx = 1;
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(idx++, cCheckLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNumTotal = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			strSql = String.format("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) AND safe_filter<=? %s ORDER BY content_id DESC LIMIT ?", strCondStart);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nUserId);
			cState.setInt(idx++, cCheckLogin.m_nSafeFilter);
			if(m_nStartId>0) {
				cState.setInt(idx++, m_nStartId);
			}
			/*
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			*/
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				m_nEndId = cContent.m_nContentId;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each append image
			GridUtil.getEachImage(cConn, m_vContentList);

			// Each Comment
			GridUtil.getEachComment(cConn, m_vContentList);

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				GridUtil.getEachBookmark(cConn, m_vContentList, cCheckLogin);
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
