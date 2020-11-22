package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class FollowListC {
	public static int MODE_FOLLOW = 0;
	public static int MODE_BLOCK = 1;

	public int m_nMode = -1;
	public int m_nPage = 0;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nMode = Math.max(Util.toInt(cRequest.getParameter("MD")), MODE_FOLLOW);
			m_nPage = Math.max(Util.toInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e) {
			;
		}
	}


	public int SELECT_MAX_GALLERY = 36;
	public ArrayList<CUser> m_vContentList = new ArrayList<CUser>();
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// NEW ARRIVAL
			if(!bContentOnly) {
				if(m_nMode==MODE_FOLLOW) {
					strSql = "SELECT count(*) FROM follows_0000 "
							+ "WHERE user_id=?";
				} else {
					strSql = "SELECT count(*) FROM blocks_0000 "
							+ "WHERE user_id=?";
				}
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if(m_nMode==MODE_FOLLOW) {
				strSql = "SELECT follow_user_id FROM follows_0000 "
						+ "WHERE user_id=? "
						+ "ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			} else {
				strSql = "SELECT block_user_id as follow_user_id FROM blocks_0000 "
						+ "WHERE user_id=? "
						+ "ORDER BY upload_date DESC OFFSET ? LIMIT ?";
			}
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, m_nPage * SELECT_MAX_GALLERY);
			statement.setInt(3, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CUser cContent = new CUser();
				cContent.m_nUserId		= resultSet.getInt("follow_user_id");
				CacheUsers0000.User user = users.getUser(cContent.m_nUserId);
				cContent.m_strNickName	= Util.toString(user.nickName);
				cContent.m_strFileName	= Util.toString(user.fileName);
				m_vContentList.add(cContent);
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
