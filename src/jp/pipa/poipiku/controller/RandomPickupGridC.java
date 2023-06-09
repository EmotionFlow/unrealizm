package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class RandomPickupGridC {

	public int m_nMode = 0;
	public int m_nStartId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nMode = Util.toInt(cRequest.getParameter("MD"));
			m_nStartId = Util.toInt(cRequest.getParameter("SD"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 24;
	public ArrayList<CContent> contentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nEndId = -1;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users = CacheUsers0000.getInstance();
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			/*
			String strMuteKeyword = "";
			String strCond = "";
			if(checkLogin.m_bLogin) {
				strSql = "SELECT mute_keyword_list FROM users_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					strMuteKeyword = Util.toString(cResSet.getString(1)).trim();
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
				/*
				strSql = String.format("SELECT count(*) FROM contents_0000 WHERE user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) %s", strCond);
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					cState.setString(idx++, strMuteKeyword);
				}
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				*/
				m_nContentsNum = SELECT_MAX_GALLERY;
			}

			StringBuilder sb = new StringBuilder();
			sb.append("SELECT contents_0000.* ");
			if(checkLogin.m_bLogin){
				sb.append(",follows_0000.follow_user_id ");
			} else {
				sb.append(",NULL as follow_user_id ");
			}
			sb.append("FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) ");
			if(checkLogin.m_bLogin){
				sb.append("LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? ");
			}
			sb.append("WHERE open_id=0 ");
			if(checkLogin.m_bLogin){
				sb.append("AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ");
			}
			sb.append("AND content_id<(SELECT (max(content_id) * random())::int ")
			.append("FROM contents_0000) AND safe_filter<=? ORDER BY content_id DESC LIMIT ? ");

			strSql = new String(sb);
			cState = cConn.prepareStatement(strSql);
			idx = 1;
			if(checkLogin.m_bLogin){
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
			}
			/*
			if(!strMuteKeyword.isEmpty()) {
				cState.setString(idx++, strMuteKeyword);
			}
			*/
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
			cState.setInt(idx++, SELECT_MAX_GALLERY);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent content = new CContent(cResSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				content.m_cUser.m_nReaction	= user.reaction;
				if(content.m_cUser.m_strFileName.isEmpty()) content.m_cUser.m_strFileName="/img/default_user.jpg";
				content.m_cUser.m_nFollowing = (content.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = content.m_nContentId;
				contentList.add(content);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			GridUtil.getEachComment(cConn, contentList);

			// Bookmark
			contentList = GridUtil.getEachBookmark(cConn, contentList, checkLogin);
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
