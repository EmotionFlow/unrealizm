package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.naming.InitialContext;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Genre;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class UpdateGenreInfoC {
	public static final int OK_PARAM = 0;
	public static final int OK_EDIT = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_TEXT_SIZE_MAX = -2;
	public static final int ERR_TEXT_SIZE_MIN = -3;
	public static final int ERR_NOT_PASSPORT = -4;
	public static final int ERR_NEED_GENRE_NAME = -5;
	public static final int ERR_SAME_GENRE_NAME = -6;
	public static final int ERR_UNKNOWN = -99;

	private final int[] TEXT_MIN = {1, 0, 0};
	private final int[] TEXT_MAX = {16, 64, 1000};
	private final String[] COLUMN = {"genre_name", "genre_desc", "genre_detail"};

	public int userId = -1;
	public int genreId = -1;
	public String data = "";
	public int type = -1;

	public int getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("UID"));
			genreId = Util.toInt(request.getParameter("GID"));
			data = Common.TrimAll(Common.CrLfInjection(Common.EscapeInjection(request.getParameter("DATA"))));
			type = Util.toInt(request.getParameter("TY"));
		} catch (Exception e) {
			userId = -1;
			genreId = -1;
			type = -1;
			return ERR_UNKNOWN;
		}
		return OK_PARAM;
	}

	public int getResults(CheckLogin checkLogin, ServletContext context) {
		if(!checkLogin.m_bLogin || checkLogin.m_nUserId!= userId) return ERR_NOT_LOGIN;
		if(checkLogin.m_nPassportId<=Common.PASSPORT_OFF) return ERR_NOT_PASSPORT;
		if(type<0 || type>=COLUMN.length) return ERR_UNKNOWN;
		if(type==0 && data.isEmpty()) return ERR_NEED_GENRE_NAME;
		if(data.length()>TEXT_MAX[type]) return ERR_TEXT_SIZE_MAX;
		if(data.length()<TEXT_MIN[type]) return ERR_TEXT_SIZE_MIN;


		int nRtn = ERR_UNKNOWN;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			// initialize DB
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// check same name
			if(type==0) {
				boolean exist = false;
				strSql = "SELECT * FROM genres WHERE genre_name=?";
				statement = connection.prepareStatement(strSql);
				statement.setString(1, data);
				resultSet = statement.executeQuery();
				exist = resultSet.next();
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				if(exist) return ERR_SAME_GENRE_NAME;
			}


			// get|generate genre id
			Genre genre = Util.getGenre(genreId);
			if(genre.genreId<1) {
				strSql = "INSERT INTO genres(create_user_id, genre_name) VALUES(?, ?) RETURNING genre_id ";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				statement.setString(2, data);
				resultSet = statement.executeQuery();
				if(resultSet.next()) {
					genreId = resultSet.getInt("genre_id");
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				if(genreId<1) return ERR_UNKNOWN;
			}

			// update making last_update
			strSql = String.format("UPDATE genres SET %s=?, update_date=CURRENT_TIMESTAMP WHERE genre_id=?",
					COLUMN[type]);
			statement = connection.prepareStatement(strSql);
			statement.setString(1, data);
			statement.setInt(2, genreId);
			statement.executeUpdate();
			statement.close();statement=null;
			genre = Util.getGenre(genreId);
			nRtn = OK_EDIT;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
