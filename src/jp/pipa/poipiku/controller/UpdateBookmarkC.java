package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class UpdateBookmarkC {
	public static final int BOOKMARK_NONE = CContent.BOOKMARK_NONE;
	public static final int BOOKMARK_BOOKMARKING = CContent.BOOKMARK_BOOKMARKING;
	public static final int BOOKMARK_LIMIT = CContent.BOOKMARK_LIMIT;
	public static final int UNKNOWN_ERROR = -1;
	public static final int USER_INVALID = -2;

	public int m_nUserId = -1;
	public int m_nContentId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Util.toInt(request.getParameter("UID"));
			m_nContentId = Util.toInt(request.getParameter("IID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int getResults(CheckLogin checkLogin) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!= m_nUserId) return USER_INVALID;

		int nRtn = UNKNOWN_ERROR;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();


			boolean bBookmarking = false;
			// now following check
			strSql ="SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nUserId);
			statement.setInt(2, m_nContentId);
			resultSet = statement.executeQuery();
			bBookmarking = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;


			if(!bBookmarking) {
				int bookmarkNum = 0;
				strSql ="SELECT count(*) FROM bookmarks_0000 WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					bookmarkNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;

				if(bookmarkNum < Common.BOOKMARK_NUM[checkLogin.m_nPassportId]) {
					strSql ="INSERT INTO bookmarks_0000(user_id, content_id) VALUES(?, ?)";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nUserId);
					statement.setInt(2, m_nContentId);
					statement.executeUpdate();
					statement.close();statement=null;
					strSql ="UPDATE contents_0000 SET bookmark_num=bookmark_num+1 WHERE content_id=?";
					statement = connection.prepareStatement(strSql);
					statement.setInt(1, m_nContentId);
					statement.executeUpdate();
					statement.close();statement=null;
					nRtn = CContent.BOOKMARK_BOOKMARKING;
				} else {
					nRtn = CContent.BOOKMARK_LIMIT;
				}
			} else {
				strSql ="DELETE FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nUserId);
				statement.setInt(2, m_nContentId);
				statement.executeUpdate();
				statement.close();statement=null;
				strSql ="UPDATE contents_0000 SET bookmark_num=bookmark_num-1 WHERE content_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.executeUpdate();
				statement.close();statement=null;
				nRtn = CContent.BOOKMARK_NONE;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}