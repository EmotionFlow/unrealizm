package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.*;

public final class MySketchbookC {
	public int userId = -1;
	public int mode = CCnv.MODE_PC;
	public int startId = -1;
	public int viewMode = CCnv.VIEW_LIST;
	public int page = 0;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			mode = Util.toInt(request.getParameter("MD"));
			startId = Util.toInt(request.getParameter("SD"));
			userId = Util.toInt(request.getParameter("ID"));
			viewMode = Util.toInt(request.getParameter("VD"));
			page =  Math.max(0, Util.toInt(request.getParameter("PG")));
		} catch(Exception ignored) {}
	}

	public int selectMaxGallery = 15;
	public ArrayList<CContent> contentList = new ArrayList<>();
	public int lastContentId = -1;
	public int contentsNum = 0;

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 1;

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			connection = DatabaseUtil.dataSource.getConnection();

			String strCondStart = (startId >0) ? " AND content_id<? " : "";

			// NEW ARRIVAL
			if(!bContentOnly) {
				contentsNum = 9999;
			}

			sql = "SELECT contents_0000.*, follows_0000.follow_user_id" +
					" FROM contents_0000" +
					"         INNER JOIN requests r ON contents_0000.content_id = r.content_id" +
					"         LEFT JOIN follows_0000 ON contents_0000.user_id = follows_0000.follow_user_id AND follows_0000.user_id = ?" +
					" WHERE r.client_user_id = ?" +
					"  AND r.status = ?" +
					"  AND safe_filter<=? " +
					strCondStart +
					" ORDER BY content_id DESC OFFSET ? LIMIT ? ";

			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, Request.Status.Done.getCode());
			statement.setInt(idx++, checkLogin.m_nSafeFilter);
			if (!strCondStart.isEmpty()) statement.setInt(idx++, startId);
			statement.setInt(idx++, startId > 0 ? 0 : page * selectMaxGallery);
			statement.setInt(idx++, selectMaxGallery);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				CContent content = new CContent(resultSet);
				CacheUsers0000.User user = users.getUser(content.m_nUserId);
				content.m_cUser.m_strNickName	= Util.toString(user.nickName);
				content.m_cUser.m_nReaction	= user.reaction;
				content.m_cUser.m_nFollowing = CUser.FOLLOW_HIDE;
				content.m_cUser.m_strFileName = Util.toString(user.fileName);
				if (checkLogin.m_bLogin) {
					content.m_cUser.m_nFollowing = (content.m_nUserId == checkLogin.m_nUserId)?CUser.FOLLOW_HIDE:(resultSet.getInt("follow_user_id")>0)?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				} else {
					content.m_cUser.m_nFollowing = CUser.FOLLOW_NONE;
				}
				lastContentId = content.m_nContentId;
				contentList.add(content);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;

			// Each Comment
			GridUtil.getEachComment(connection, contentList);

			// Bookmark
			GridUtil.getEachBookmark(connection, contentList, checkLogin);

		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){}
		}
		return bResult;
	}
}
