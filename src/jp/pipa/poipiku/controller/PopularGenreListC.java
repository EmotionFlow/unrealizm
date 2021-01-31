package jp.pipa.poipiku.controller;

import java.sql.*;
import java.util.ArrayList;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.*;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

public class PopularGenreListC {
	public int m_nPage = 0;
	public int order = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Util.toInt(request.getParameter("PG")), 0);
			order = Util.toIntN(request.getParameter("OD"), 0, 2);
		}
		catch(Exception e) {
			;
		}
	}

	public int SELECT_MAX = 50;
	public int contentsNum = 0;
	public ArrayList<Genre> contents = new ArrayList<>();

	public boolean getResults(CheckLogin checkLogin) {
		boolean bResult = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			strSql = "SELECT COUNT(*) FROM genres";
			statement = connection.prepareStatement(strSql);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contentsNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			String condOrder = "update_date";
			switch(order) {
			case 1:
				condOrder = "content_num_total";
				break;
			case 2:
				condOrder = "content_num_week";
				break;
			default:
				break;
			}

			strSql = String.format("SELECT * FROM genres ORDER BY %s DESC OFFSET ? LIMIT ?", condOrder);
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nPage*SELECT_MAX);
			statement.setInt(2, SELECT_MAX);
			resultSet = statement.executeQuery();
			while (resultSet.next()) {
				contents.add(new Genre(resultSet));
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
