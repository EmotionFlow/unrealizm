package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.CodeEnum;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.UserGroup;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AddSwitchUserC extends Controller {
	public int loginUserId = -1;
	public int switchUserId = -1;
	public String switchUserEmail = "";
	public String switchUserPassword = "";

	public ErrorDetail errorDetail= ErrorDetail.Unknown;
	public enum ErrorDetail implements CodeEnum<AddSwitchUserC.ErrorDetail> {
		None(0),
		AuthError(-10),	    // 認証エラー
		FoundMe(-20),	        // 自分のアカウントが見つかった
		FoundOtherGroup(-30), // 指定ユーザーはすでに他のグループに入っている
		Unknown(-99);         // 不明。通常ありえない。

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private ErrorDetail(int code) {
			this.code = code;
		}
	}


	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			loginUserId = Util.toInt(request.getParameter("ID"));
			switchUserEmail = Util.toString(request.getParameter("EM"));
			switchUserPassword = Util.toString(request.getParameter("PW"));
		} catch(Exception ignored) { }
	}

	public boolean getResults(CheckLogin checkLogin, HttpServletResponse response) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != loginUserId) {
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

			// メアド、PWからユーザーを検索
			strSql = "SELECT user_id, hash_password FROM users_0000 WHERE email=? AND password=?";
			statement = connection.prepareStatement(strSql);
			statement.setString(1, switchUserEmail.toLowerCase());
			statement.setString(2, switchUserPassword);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				switchUserId = resultSet.getInt("user_id");
				hashPass = resultSet.getString("hash_password");
			} else {
				errorKind = ErrorKind.DoRetry;
				errorDetail = ErrorDetail.AuthError;
				return false;
			}

			if (switchUserId == loginUserId) {
				errorKind = ErrorKind.DoRetry;
				errorDetail = ErrorDetail.FoundMe;
				return false;
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

		UserGroup userGroup;
		userGroup = new UserGroup(switchUserId);
		if (userGroup.groupId > 0) {
			// すでに他のグループに追加されている
			errorKind = ErrorKind.DoRetry;
			errorDetail = ErrorDetail.FoundOtherGroup;
			return false;
		}

		userGroup = new UserGroup(loginUserId);
		if (!userGroup.contain(switchUserId)) {
			boolean addResult = userGroup.add(switchUserId);
			if (!addResult) {
				errorKind = ErrorKind.DoRetry;
				errorDetail = ErrorDetail.Unknown;
				return false;
			}
		}

		// LK更新
		if(!hashPass.isEmpty()) {
			Cookie cLK = new Cookie(Common.AI_POIPIKU_LK, hashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);
		}

		errorKind = ErrorKind.None;
		errorDetail = ErrorDetail.None;
		return true;
	}
}
