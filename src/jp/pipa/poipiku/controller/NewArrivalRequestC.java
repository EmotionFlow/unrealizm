package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SqlUtil;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public final class NewArrivalRequestC extends Controller{

	public int m_nCategoryId = 0;
	public int m_nPage = 0;
	public void getParam(final HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nCategoryId = Math.min(Util.toInt(cRequest.getParameter("CD")), Common.CATEGORY_ID_MAX);
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX_GALLERY = 15;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean getResults(final CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(final CheckLogin checkLogin, final boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();

			connection = DatabaseUtil.dataSource.getConnection();

			String strCondCat = (m_nCategoryId>=0)?" AND category_id=?":"";

			// BLOCK USER
			String strCondBlockUser = "";
			if(SqlUtil.hasBlockUser(connection, checkLogin.m_nUserId)) {
				strCondBlockUser = "AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) ";
			}

			// BLOCKED USER
			String strCondBlocedkUser = "";
			if(SqlUtil.hasBlockedUser(connection, checkLogin.m_nUserId)) {
				strCondBlocedkUser = "AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ";
			}

			// MUTE KEYWORD
			String strMuteKeyword = "";
			String strCondMute = "";
			if(checkLogin.m_bLogin && checkLogin.m_nPassportId >=Common.PASSPORT_ON) {
				strMuteKeyword = SqlUtil.getMuteKeyWord(connection, checkLogin.m_nUserId);
				if(!strMuteKeyword.isEmpty()) {
					strCondMute = "AND content_id NOT IN(SELECT content_id FROM contents_0000 WHERE description &@~ ?) ";
				}
			}

			// NEW ARRIVAL
			if(!bContentOnly) {
				m_nContentsNum = 9999;
			}

			strSql = "SELECT * FROM contents_0000 "
					+ "WHERE"
					+ " content_id in (select content_id from requests where content_id is not null order by id desc limit 1000)"
					+ " AND open_id=0 "
					+ " AND safe_filter<=? "
					+ strCondBlockUser
					+ strCondBlocedkUser
					+ strCondCat
					+ strCondMute
					+ "ORDER BY content_id DESC OFFSET ? LIMIT ? ";
			Log.d(strSql);
			statement = connection.prepareStatement(strSql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if(!strCondBlockUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if(!strCondBlocedkUser.isEmpty()) {
				statement.setInt(idx++, checkLogin.m_nUserId);
			}
			if(!strCondCat.isEmpty()){
				statement.setInt(idx++, m_nCategoryId);
			}
			if(!strCondMute.isEmpty()){
				statement.setString(idx++, strMuteKeyword);
			}
			statement.setInt(idx++, m_nPage * SELECT_MAX_GALLERY);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_strFileName	= Util.toString(user.fileName);
				m_nEndId = content.m_nContentId;
				m_vContentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}
