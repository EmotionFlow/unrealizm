package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class FollowListC {
	public static int MODE_FOLLOWING = 0;
	public static int MODE_FOLLOWER = 1;

	public int userId = -1;
	public int m_nMode = -1;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			userId = Util.toInt(cRequest.getParameter("ID"));
			m_nMode = Math.max(Util.toInt(cRequest.getParameter("MD")), MODE_FOLLOWING);
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}

	public int selectMaxGallery = 36;
	public ArrayList<CUser> userList = new ArrayList<>();
	public int userNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		if (userId < 0) return false;

		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			if(!bContentOnly) {
				if(m_nMode== MODE_FOLLOWING) {
					strSql = "SELECT count(*) FROM follows_0000 "
							+ "WHERE user_id=?";
				} else {
					strSql = "SELECT count(*) FROM follows_0000 "
							+ "WHERE follow_user_id=?";
				}
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, userId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					userNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if(m_nMode== MODE_FOLLOWING) {
				strSql = "SELECT follow_user_id FROM follows_0000 f "
						+ "INNER JOIN users_0000 u ON f.follow_user_id=u.user_id "
						+ "WHERE f.user_id=? "
						+ "ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			} else {
				strSql = "SELECT f.user_id as follower_user_id FROM follows_0000 f "
						+ "INNER JOIN users_0000 u ON f.user_id=u.user_id "
						+ "WHERE f.follow_user_id=? "
						+ "ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			}
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, m_nPage * selectMaxGallery);
			statement.setInt(3, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CUser cContent = new CUser();

				if (m_nMode == MODE_FOLLOWING) {
					cContent.m_nUserId = resultSet.getInt("follow_user_id");
				} else {
					cContent.m_nUserId = resultSet.getInt("follower_user_id");
				}

				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				if (user != null) {
					cContent.m_strNickName	= Util.toString(user.nickName);
					cContent.m_strFileName	= Util.toString(user.fileName);
					userList.add(cContent);
				}
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
