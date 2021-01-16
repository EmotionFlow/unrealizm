package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class PopularIllustListGridC {

	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 24;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
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

			StringBuilder sb = new StringBuilder();

			// POPULAR
			if(!bContentOnly) {
				//strSql = "SELECT count(*) FROM vw_rank_contents_total WHERE user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) AND safe_filter<=?";
				sb.append("SELECT count(*)")
				.append(" FROM contents_0000")
				.append(" INNER JOIN rank_contents_total ON contents_0000.content_id=rank_contents_total.content_id")
				.append(" WHERE open_id<>2");
				if(checkLogin.m_bLogin){
					sb.append(" AND rank_contents_total.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?)")
					.append(" AND rank_contents_total.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)");
				}
				sb.append(" AND safe_filter<=?");

				strSql = new String(sb);
				sb.setLength(0);
				cState = cConn.prepareStatement(strSql);
				idx = 1;
				if(checkLogin.m_bLogin){
					cState.setInt(idx++, checkLogin.m_nUserId);
					cState.setInt(idx++, checkLogin.m_nUserId);
				}
				cState.setInt(idx++, checkLogin.m_nSafeFilter);
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

			sb.append("SELECT contents_0000.* ");
			if(checkLogin.m_bLogin){
				sb.append(", follows_0000.follow_user_id");
			} else {
				sb.append(", NULL as follow_user_id");
			}
			sb.append("FROM ( ")
			.append("(contents_0000 INNER JOIN rank_contents_total ON contents_0000.content_id=rank_contents_total.content_id) ")
			.append("INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id ")
			.append(") ");
			if(checkLogin.m_bLogin){
				sb.append("LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? ");
			}
			sb.append("WHERE open_id<>2 ");
			if(checkLogin.m_bLogin){
				sb.append("AND rank_contents_total.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ")
				.append("AND rank_contents_total.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ");
			}
			sb.append("AND safe_filter<=? ");
			sb.append("ORDER BY rank_contents_total.add_date DESC NULLS LAST OFFSET ? LIMIT ? ");
			strSql = new String(sb);

			cState = cConn.prepareStatement(strSql);
			idx = 1;
			if(checkLogin.m_bLogin){
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
				cState.setInt(idx++, checkLogin.m_nUserId);
			}
			cState.setInt(idx++, checkLogin.m_nSafeFilter);
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
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_cUser.m_strNickName	= Util.toString(user.nickName);
				cContent.m_cUser.m_strFileName	= Util.toString(user.fileName);
				cContent.m_cUser.m_nReaction	= user.reaction;
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
				cContent.m_cUser.m_nFollowing = (cContent.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(cResSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_vContentList.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bResult = true;

			// Each Comment
			m_vContentList = GridUtil.getEachComment(cConn, m_vContentList);
			// Bookmark
			m_vContentList = GridUtil.getEachBookmark(cConn, m_vContentList, checkLogin);
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
