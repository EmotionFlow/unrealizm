package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

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
			m_nUserId		= Util.toInt(cRequest.getParameter("ID"));
			m_nContentId	= Util.toInt(cRequest.getParameter("TD"));
			m_nPage 		= Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
			m_nMode 		= Util.toInt(cRequest.getParameter("MD"));
			m_bAdFilter		= (Util.toInt(cRequest.getParameter("ADF"))>=2);
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> contentList = new ArrayList<>();
	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_nUserId != checkLogin.m_nUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cState.setInt(2, m_nUserId);
				cResSet = cState.executeQuery();
				boolean bFollow = cResSet.next();
				m_nFollow = (bFollow)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				if(bFollow) {
					checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_MAX);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {	// owner
				checkLogin.m_nSafeFilter = Math.max(checkLogin.m_nSafeFilter, Common.SAFE_FILTER_MAX);
			}

			// author profile
			CUser cUser = new CUser();
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cUser.m_nUserId				= cResSet.getInt("user_id");
				cUser.m_strNickName			= Util.toString(cResSet.getString("nickname"));
				cUser.m_strProfile			= Util.toString(cResSet.getString("profile"));
				cUser.m_strFileName			= Util.toString(cResSet.getString("file_name"));
				cUser.m_strHeaderFileName	= Util.toString(cResSet.getString("header_file_name"));
				cUser.m_strBgFileName		= Util.toString(cResSet.getString("bg_file_name"));
				cUser.m_nReaction			= cResSet.getInt("ng_reaction");
				if(cUser.m_strFileName.isEmpty()) cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cUser.m_nUserId<=0) return false;

			if(cUser.m_strHeaderFileName.isEmpty()) {
				strSql = "SELECT file_name FROM contents_0000 WHERE publish_id=0 AND open_id<>2 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					cUser.m_strHeaderFileName	= Util.toString(cResSet.getString("file_name")) + "_640.jpg";
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {
				cUser.m_strHeaderFileName += "_640.jpg";
			}

			// NEW ARRIVAL
			String strOpenCnd = (m_nUserId!=checkLogin.m_nUserId)?" AND open_id<>2":"";
			strSql = String.format("SELECT * FROM contents_0000 WHERE user_id=? AND content_id<? AND safe_filter<=? %s ORDER BY content_id DESC OFFSET ? LIMIT ?", strOpenCnd);
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setInt(2, m_nContentId);
			cState.setInt(3, checkLogin.m_nSafeFilter);
			cState.setInt(4, SELECT_MAX_GALLERY*m_nPage);
			cState.setInt(5, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent content = new CContent(cResSet);
				content.m_cUser.m_strNickName	= cUser.m_strNickName;
				content.m_cUser.m_strFileName	= cUser.m_strFileName;
				content.m_cUser.m_nFollowing	= m_nFollow;
				content.m_cUser.m_nReaction	= cUser.m_nReaction;
				contentList.add(content);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			if(cUser.m_nReaction==CUser.REACTION_SHOW) {
				GridUtil.getEachComment(cConn, contentList);
			}

			// Bookmark
			GridUtil.getEachBookmark(cConn, contentList, checkLogin);
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
