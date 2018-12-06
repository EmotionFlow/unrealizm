package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class MyHomeC {
	public int m_nPage = 0;
	public int n_nVersion = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
			n_nVersion = Common.ToInt(cRequest.getParameter("VER"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = 60;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;

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
			}

			//strSql = String.format("SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) AND safe_filter<=? %s ORDER BY content_id DESC OFFSET ? LIMIT ?", strCond);
			strSql = "SELECT contents_0000.*, nickname, ng_reaction, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.user_id IN ((SELECT follow_user_id FROM follows_0000 WHERE user_id=?) UNION ALL (SELECT ?)) AND safe_filter<=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
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
			cState.setInt(idx++, SELECT_MAX_GALLERY*m_nPage);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nReaction = cResSet.getInt("ng_reaction");
				cContent.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Each append image
			strSql = "SELECT * FROM contents_appends_0000 WHERE content_id=? ORDER BY append_id ASC LIMIT 1000";
			cState = cConn.prepareStatement(strSql);
			for(CContent cContent : m_vContentList) {
				if(cContent.m_nFileNum<=1) continue;
				cState.setInt(1, cContent.m_nContentId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					cContent.m_vContentAppend.add(new CContentAppend(cResSet));
				}
				cResSet.close();cResSet=null;
			}
			cState.close();cState=null;

			// Each Comment
			strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			for(CContent cContent : m_vContentList) {
				if(cContent.m_cUser.m_nReaction!=CUser.REACTION_SHOW) continue;
				cState.setInt(1, cContent.m_nContentId);
				cState.setInt(2, SELECT_MAX_EMOJI);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cComment = new CComment(cResSet);
					cContent.m_vComment.add(0, cComment);
				}
				cResSet.close();cResSet=null;
			}
			cState.close();cState=null;

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				strSql = "SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				for(CContent cContent : m_vContentList) {
					cState.setInt(1, cCheckLogin.m_nUserId);
					cState.setInt(2, cContent.m_nContentId);
					cResSet = cState.executeQuery();
					if (cResSet.next()) {
						cContent.m_nBookmarkState = CContent.BOOKMARK_BOOKMARKING;
					}
					cResSet.close();cResSet=null;
				}
				cState.close();cState=null;
			}
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
