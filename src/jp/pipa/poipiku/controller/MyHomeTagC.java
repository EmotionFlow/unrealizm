package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class MyHomeTagC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nMode = CCnv.MODE_PC;
	public int m_nStartId = -1;
	public int m_nViewMode = CCnv.VIEW_LIST;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(cRequest.getParameter("VER"));
			m_nMode = Util.toInt(cRequest.getParameter("MD"));
			m_nStartId = Util.toInt(cRequest.getParameter("SD"));
			n_nUserId = Util.toInt(cRequest.getParameter("ID"));
			m_nViewMode = Util.toInt(cRequest.getParameter("VD"));
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 10;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

	public boolean getResults(CheckLogin cCheckLogin) {
		return getResults(cCheckLogin, false);
	}

	public boolean getResults(CheckLogin cCheckLogin, boolean bContentOnly) {
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// サーチタグの存在確認
			boolean bSearchTag = false;
			strSql = "SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0 LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cCheckLogin.m_nUserId);
			resultSet = statement.executeQuery();
			bSearchTag = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// サーチキーワード
			strSql = "SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=1 LIMIT 100";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cCheckLogin.m_nUserId);
			resultSet = statement.executeQuery();
			StringBuilder sbKeyWord = new StringBuilder();
			if(resultSet.next()) {
				sbKeyWord.append(Util.toString(resultSet.getString(1)).trim());
				while (resultSet.next()) {
					sbKeyWord.append(" OR ");
					sbKeyWord.append(Util.toString(resultSet.getString(1)).trim());
				}
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			String strSearchKeyword = sbKeyWord.toString();
			String strCondSearch = (!strSearchKeyword.isEmpty())?"OR contents_0000.content_id IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ":"";

			// サーチタグ&サーチキーワード共に無い場合はそのまま終了
			if (!bSearchTag && strSearchKeyword.isEmpty()) return true;

			// ブロックユーザクエリ
			String strCondBlock = "";
			strSql = "SELECT block_user_id FROM blocks_0000 WHERE user_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cCheckLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				strCondBlock = "AND contents_0000.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 非ブロックユーザクエリ
			String strCondBlocked = "";
			strSql = "SELECT user_id FROM blocks_0000 WHERE block_user_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cCheckLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				strCondBlocked = "AND contents_0000.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 無限スクロール用のスタートポジションクエリ
			String strCondStart = (m_nStartId>0)?" AND contents_0000.content_id<?":"";

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(cCheckLogin.m_bLogin && cCheckLogin.m_nPremiumId>=CUser.PREMIUM_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, cCheckLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// NEW ARRIVAL
			if(!bContentOnly) {
				// PC版右ペイン用
				idx = 1;
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(idx++, cCheckLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNumTotal = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			strSql = "SELECT contents_0000.*, follows_0000.follow_user_id "
					+ "FROM contents_0000 "
					+ "LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? "
					+ "WHERE open_id<>2 "
					+ strCondBlock
					+ strCondBlocked
					+ "AND safe_filter<=? "
					+ "AND (content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt IN(SELECT tag_txt FROM follow_tags_0000 WHERE user_id=? AND type_id=0) AND tag_type=1) "
					+ strCondSearch
					+ ") "
					+ strCondMute
					+ strCondStart
					+ "ORDER BY content_id DESC LIMIT ?";
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, cCheckLogin.m_nUserId); // follows_0000.user_id=?
			if(!strCondBlock.isEmpty()) statement.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.user_id=?
			if(!strCondBlocked.isEmpty()) statement.setInt(idx++, cCheckLogin.m_nUserId); // blocks_0000.block_user_id=?
			statement.setInt(idx++, cCheckLogin.m_nSafeFilter); // safe_filter<=?
			statement.setInt(idx++, cCheckLogin.m_nUserId); // follow_tags_0000.user_id=?
			if(!strCondSearch.isEmpty()) statement.setString(idx++, strSearchKeyword);
			if(!strCondMute.isEmpty()) statement.setString(idx++, strMuteKeyword);
			if(!strCondStart.isEmpty()) statement.setInt(idx++, m_nStartId); // content_id<?
			statement.setInt(idx++, SELECT_MAX_GALLERY); // LIMIT ?
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.m_strNickName);
				content.m_cUser.m_strFileName	= Util.toString(user.m_strFileName);
				content.m_cUser.m_nReaction		= user.m_nReaction;
				content.m_cUser.m_nFollowing = (content.m_nUserId == cCheckLogin.m_nUserId)?CUser.FOLLOW_HIDE:(resultSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = content.m_nContentId;
				m_vContentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			GridUtil.getEachComment(connection, m_vContentList);

			// Bookmark
			if(cCheckLogin.m_bLogin) {
				GridUtil.getEachBookmark(connection, m_vContentList, cCheckLogin);
			}
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}

