package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public class MyBookmarkC {

	public int page = 0;
	public int startId = 0;
	public boolean noContents = false;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			page = Math.max(Util.toInt(request.getParameter("PG")), 0);
			startId = Util.toInt(request.getParameter("SD"));
		} catch(Exception ignored) {
			;
		}
	}

	public int selectMaxGallery = 36;
	public ArrayList<CContent> m_vContentList = new ArrayList<>();
	public int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			String strSqlFromWhere = " FROM contents_0000"
					+ " INNER JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id"
					+ " WHERE open_id<>2 AND bookmarks_0000.user_id=?";

			// NEW ARRIVAL
			if(!bContentOnly) {
				strSql = "SELECT count(*) " + strSqlFromWhere;
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}

			if (!noContents) {
				if (startId > 0) {
					strSqlFromWhere += " AND bookmark_id<" + startId;
				}
				strSql = "SELECT bookmark_id, contents_0000.* " + strSqlFromWhere + " ORDER BY bookmarks_0000.bookmark_id DESC";
				if (startId <= 0) {
					strSql += String.format(" OFFSET %d", page * selectMaxGallery);
				}
				strSql += String.format(" LIMIT %d", selectMaxGallery);

				Log.d(strSql);

				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				while (resultSet.next()) {
					CContent content = new CContent(resultSet);
					CacheUsers0000.User user = users.getUser(content.m_nUserId);
					content.m_cUser.m_strNickName	= Util.toString(user.nickName);
					content.m_cUser.m_strFileName	= Util.toString(user.fileName);
					m_nEndId = resultSet.getInt("bookmark_id");
					m_vContentList.add(content);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}
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
