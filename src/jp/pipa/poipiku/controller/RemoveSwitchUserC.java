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

public class RemoveSwitchUserC extends Controller {
	public int removeUserId = -1;

	public ErrorDetail errorDetail= ErrorDetail.Unknown;
	public enum ErrorDetail implements CodeEnum<RemoveSwitchUserC.ErrorDetail> {
		None(0),
		RemoveMe(-10),	    // 自分を外そうとした
		NotFound(-20),	    // 削除対象が見つからなかった
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
			removeUserId = Util.toInt(request.getParameter("ID"));
		} catch(Exception ignored) { }
	}

	public boolean getResults(CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin) {
			errorKind = ErrorKind.Unknown;
			return false;
		}
		if (checkLogin.m_nUserId == removeUserId) {
			errorKind = ErrorKind.DoRetry;
			errorDetail = ErrorDetail.RemoveMe;
			return false;
		}

		UserGroup userGroup = new UserGroup(checkLogin.m_nUserId);
		if (userGroup.contain(removeUserId)) {
			boolean removeResult = userGroup.remove(removeUserId);
			if (!removeResult) {
				errorKind = ErrorKind.DoRetry;
				errorDetail = ErrorDetail.Unknown;
				return false;
			}
		} else {
			errorKind = ErrorKind.DoRetry;
			errorDetail = ErrorDetail.NotFound;
			return false;
		}

		errorKind = ErrorKind.None;
		errorDetail = ErrorDetail.None;
		return true;
	}
}
