package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SendRequestC {
	public int creatorUserId = -1;
	public String accessIpAddress = "";
	public RequestCreator requestCreator = null;
	public CUser user = new CUser();

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			creatorUserId = Util.toInt(request.getParameter("ID"));
			accessIpAddress = request.getRemoteAddr();
		} catch(Exception e) {
			creatorUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;

		if(creatorUserId < 1) {
			Log.d("creatorUserId < 1");
			return false;
		}else if(checkLogin.m_nUserId == creatorUserId){
			return true;
		}

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

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
				user.m_nMailComment		= resultSet.getInt("mail_comment");
				if(user.m_strFileName.isEmpty()) user.m_strFileName="/img/default_user.jpg";
				user.m_bRequestEnabled   = (
						resultSet.getInt("request_creator_status") == RequestCreator.Status.Enabled.getCode()
				);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if(user.m_strHeaderFileName.isEmpty()) {
				strSql = "SELECT * FROM contents_0000 WHERE publish_id=0 AND safe_filter=0 AND user_id=? ORDER BY content_id DESC LIMIT 1";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, creatorUserId);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					user.m_strHeaderFileName	= Util.toString(resultSet.getString("file_name"));
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
			}
			requestCreator = new RequestCreator(creatorUserId);
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
