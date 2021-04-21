package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;


public final class MyHomeTagPcC {
	public int n_nUserId = -1;
	public int n_nVersion = 0;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			n_nVersion = Util.toInt(cRequest.getParameter("VER"));
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 15;
	public int SELECT_MAX_EMOJI = GridUtil.SELECT_MAX_EMOJI;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nContentsNum = 0;
	public int m_nContentsNumTotal = 0;
	public int m_nEndId = -1;

	public boolean getResults(CheckLogin checkLogin) {
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			final String subTable = "WITH t as (" +
					"SELECT contents_0000.*, follows_0000.follow_user_id FROM contents_0000 " +
					" LEFT JOIN follows_0000 ON contents_0000.user_id=follows_0000.follow_user_id AND follows_0000.user_id=? " +
					" WHERE open_id<>2 " +
					" AND safe_filter<=? AND (" +
					"   content_id IN (" +
					"     SELECT content_id FROM tags_0000 WHERE genre_id IN(" +
					"       SELECT genre_id FROM follow_tags_0000 WHERE user_id=?" +
					"     ) AND tag_type=1 ORDER BY content_id DESC LIMIT 1000" +
					"   ) " +
					" )" +
					" LIMIT 10000" +
					")";

			// BLOCK USER
			final String strCondBlockUser = "t.user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";

			// BLOCKED USER
			final String strCondBlocedkUser = "t.user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// get contents
			idx = 1;
			strSql = "SELECT COUNT(*) FROM contents_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(idx++, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNumTotal = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			List<String> conditions = new ArrayList<>();
			conditions.add(strCondBlockUser);
			conditions.add(strCondBlocedkUser);
			if (!strCondMute.isEmpty()) conditions.add(strCondMute);

			strSql = subTable +
					" SELECT count(t.*) FROM t";
			if (!conditions.isEmpty()) {
				strSql += " WHERE " + String.join(" AND ", conditions);
			}

			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);        // follows_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nSafeFilter);    // safe_filter<=?
			statement.setInt(idx++, checkLogin.m_nUserId);        // follow_tags_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nUserId);      // blocks_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nUserId);    // blocks_0000.block_user_id=?
			if(!strCondMute.isEmpty()) statement.setString(idx++, strMuteKeyword);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				m_nContentsNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			strSql = subTable +
					" SELECT * FROM t";
			if (!conditions.isEmpty()) {
				strSql += " WHERE " + String.join(" AND ", conditions);
			}
			strSql += " ORDER BY content_id DESC OFFSET ? LIMIT ?";

			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);      // follows_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nSafeFilter);  // safe_filter<=?
			statement.setInt(idx++, checkLogin.m_nUserId);      // follow_tags_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nUserId);      // blocks_0000.user_id=?
			statement.setInt(idx++, checkLogin.m_nUserId);    // blocks_0000.block_user_id=?
			if(!strCondMute.isEmpty()) statement.setString(idx++, strMuteKeyword);
			statement.setInt(idx++, m_nPage * SELECT_MAX_GALLERY); // OFFSET ?
			statement.setInt(idx++, SELECT_MAX_GALLERY);              // LIMIT ?
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				content.m_cUser.m_nReaction		= user.reaction;
				content.m_cUser.m_nFollowing	= (content.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(resultSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				m_nEndId = content.m_nContentId;
				m_vContentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Each Comment
			m_vContentList = GridUtil.getEachComment(connection, m_vContentList);

			// Bookmark
			m_vContentList = GridUtil.getEachBookmark(connection, m_vContentList, checkLogin);
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

