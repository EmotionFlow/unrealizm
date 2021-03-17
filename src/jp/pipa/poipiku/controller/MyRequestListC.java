package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Request;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class MyRequestListC {
	public int pageNum = 0;
	public String category = "";
	public int statusCode = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			category = Common.TrimAll(request.getParameter("CAT"));
			statusCode = Util.toInt(Common.TrimAll(request.getParameter("ST")));
			pageNum = Math.max(Util.toInt(request.getParameter("PG")), 0);
		} catch(Exception e) {
			;
		}
	}

	public static class Result {
		public Request request;
		public String nickname;
		public String profileFileName;
		public String contentFileName;
		Result(ResultSet resultSet) throws SQLException {
			request = new Request(resultSet);
			nickname = resultSet.getString("nickname");
			profileFileName = resultSet.getString("profile_file_name");
			contentFileName = resultSet.getString("content_file_name");
		}
	}

	public int SELECT_MAX_GALLERY = 1000;
	public ArrayList<MyRequestListC.Result> requests = new ArrayList<>();

	public boolean getResults(CheckLogin checkLogin) {
		return getResults(checkLogin, false);
	}

	public boolean getResults(CheckLogin checkLogin, boolean bContentOnly) {
		boolean bResult = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		int idx = 1;

		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();
			sql = "SELECT r.*, u.nickname, u.file_name profile_file_name, c.file_name content_file_name FROM requests r" +
					" INNER JOIN users_0000 u ON(" + (category.equals("SENT") ? "r.creator_user_id" : "r.client_user_id") + "=u.user_id)" +
					" LEFT JOIN contents_0000 c ON(r.content_id=c.content_id)" +
					" WHERE " + (category.equals("SENT") ? "r.client_user_id" : "r.creator_user_id") + "=?" +
					" AND r.status = ?" +
					" ORDER BY updated_at DESC OFFSET ? LIMIT ?";
			statement = connection.prepareStatement(sql);
			idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, statusCode);
			statement.setInt(idx++, pageNum * SELECT_MAX_GALLERY);
			statement.setInt(idx++, SELECT_MAX_GALLERY);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				requests.add(new MyRequestListC.Result(resultSet));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			bResult = true;
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}
