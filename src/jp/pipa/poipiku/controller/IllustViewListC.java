package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class IllustViewListC {
	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nPage = 0;
	public int m_nMode = 0;
	public boolean m_bAdFilter = false;

	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
			m_nPage 		= Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
			m_nMode 		= Common.ToInt(cRequest.getParameter("MD"));
			m_bAdFilter		= (Common.ToInt(cRequest.getParameter("ADF"))>=2);
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}


	public int SELECT_MAX_GALLERY = 20;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_nUserId != cCheckLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cCheckLogin.m_nUserId);
				cState.setInt(2, m_nUserId);
				cResSet = cState.executeQuery();
				m_nFollow = (cResSet.next())?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}

			// author profile
			CUser cUser = new CUser();
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cUser.m_nUserId				= cResSet.getInt("user_id");
				cUser.m_strNickName			= Common.ToString(cResSet.getString("nickname"));
				cUser.m_strProfile			= Common.ToString(cResSet.getString("profile"));
				cUser.m_strFileName			= Common.ToString(cResSet.getString("file_name"));
				cUser.m_strHeaderFileName	= Common.ToString(cResSet.getString("header_file_name"));
				cUser.m_strBgFileName		= Common.ToString(cResSet.getString("bg_file_name"));
				cUser.m_nReaction			= cResSet.getInt("ng_reaction");
				if(cUser.m_strFileName.isEmpty()) cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cUser.m_nUserId<=0) return false;


			// NEW ARRIVAL
			strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id<? AND safe_filter<=? ORDER BY content_id DESC OFFSET ? LIMIT ?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cState.setInt(3, cCheckLogin.m_nSafeFilter);
			cState.setInt(4, SELECT_MAX_GALLERY*m_nPage);
			cState.setInt(5, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= cUser.m_strNickName;
				cContent.m_cUser.m_strFileName	= cUser.m_strFileName;
				cContent.m_cUser.m_nFollowing	= m_nFollow;
				cContent.m_cUser.m_nReaction	= cUser.m_nReaction;
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
			if(cUser.m_nReaction==CUser.REACTION_SHOW) {
				strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT 240";
				cState = cConn.prepareStatement(strSql);
				for(CContent cContent : m_vContentList) {
					cState.setInt(1, cContent.m_nContentId);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						CComment cComment = new CComment(cResSet);
						cContent.m_vComment.add(0, cComment);
					}
					cResSet.close();cResSet=null;
				}
				cState.close();cState=null;
			}

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
