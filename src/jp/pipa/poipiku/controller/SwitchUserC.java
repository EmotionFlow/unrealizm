package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SwitchUserC extends Controller {
	public int switchUserId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			switchUserId = Util.toInt(request.getParameter("SWID"));
		} catch(Exception ignored) { }
	}

	public boolean getResults(CheckLogin checkLogin, HttpServletResponse response) {
		if (!checkLogin.m_bLogin) {
			errorKind = ErrorKind.Unknown;
			return false;
		}
		if (checkLogin.m_nUserId == switchUserId) {
			return true;
		}

		UserGroup userGroup = new UserGroup(checkLogin.m_nUserId);
		if (!userGroup.contain(switchUserId)) {
			Log.d("関連づけていないユーザへの切り替え要求");
			errorKind = ErrorKind.Unknown;
			return false;
		}

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";
		String hashPass = "";
		try {
			connection = DatabaseUtil.dataSource.getConnection();
			strSql = "SELECT hash_password FROM users_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, switchUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				hashPass = Util.toString(resultSet.getString("hash_password"));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}

		if(!hashPass.isEmpty()) {
			Cookie cLK = new Cookie(Common.UNREALIZM_LK, hashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
		}
		return true;
	}
}
