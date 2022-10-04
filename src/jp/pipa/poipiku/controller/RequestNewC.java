package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.SqlUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RequestNewC {
	public int creatorUserId = -1;
	public String accessIpAddress = "";
	public RequestCreator requestCreator = null;
	public CUser user = new CUser();
	public boolean isBlocking = false;
	public boolean isBlocked = false;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			creatorUserId = Util.toInt(request.getParameter("ID"));
			accessIpAddress = request.getRemoteAddr();
		} catch(Exception e) {
			creatorUserId = -1;
		}
	}

	public boolean isReachedLimit;
	public boolean getResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		if(creatorUserId < 1) {
			Log.d("creatorUserId < 1");
			return false;
		}

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// creator profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, creatorUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				user.m_nUserId			= resultSet.getInt("user_id");
				user.m_strNickName		= Util.toString(resultSet.getString("nickname"));
				user.m_strProfile		= Util.toString(resultSet.getString("profile"));
				user.m_strFileName		= Util.toString(resultSet.getString("file_name"));
				user.m_strHeaderFileName	= Util.toString(resultSet.getString("header_file_name"));
				user.m_strBgFileName		= Util.toString(resultSet.getString("bg_file_name"));
				if(user.m_strFileName.isEmpty()) user.m_strFileName="/img/default_user.jpg";
				user.setRequestEnabled(resultSet);
				user.m_nPassportId      = resultSet.getInt("passport_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(user.m_strHeaderFileName.isEmpty()) {
				user.m_strHeaderFileName = SqlUtil.getRecentlyPublicImageFileName(connection, creatorUserId);
			} else {
				user.m_strHeaderFileName += "_640.jpg";
			}
			requestCreator = new RequestCreator(creatorUserId);

			// blocking
			strSql = "SELECT user_id FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, checkLogin.m_nUserId);
			statement.setInt(2, creatorUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				isBlocking = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// blocked
			strSql = "SELECT user_id FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, creatorUserId);
			statement.setInt(2, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				isBlocked = true;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// check limit
			isReachedLimit = Request.isReachedSendLimit(checkLogin.m_nUserId);

			bRtn = true;
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
