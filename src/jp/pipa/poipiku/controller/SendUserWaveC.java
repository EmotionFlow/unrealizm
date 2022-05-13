package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;

public class SendUserWaveC {
	public String emoji = "";
	public int fromUserId = -1;
	public int toUserId = -1;
	private String ipAddress = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			emoji = Util.toString(request.getParameter("EMOJI")).trim();
			fromUserId = Util.toInt(request.getParameter("FROMUID"));
			toUserId = Util.toInt(request.getParameter("TOUID"));
			String remoteAddr = request.getRemoteAddr();
			if (remoteAddr != null && !remoteAddr.isEmpty()) {
				ipAddress	= remoteAddr;
			}
		} catch(Exception e) {
			e.printStackTrace();
			toUserId = -1;
		}
	}

	public String message = "";
	public boolean getResults(final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
		message = _TEX.T("IllustV.Wave.SendNG");
		if (toUserId < 0) {
			return false;
		}
		if (!Arrays.asList(Emoji.EMOJI_ALL).contains(emoji)) {
			Log.d("Invalid Emoji : " + emoji);
			return false;
		}
		if (checkLogin.m_bLogin && (fromUserId != checkLogin.m_nUserId)) {
			Log.d("ログインしているのにUserIdが異なる");
			return false;
		}

		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement("SELECT 1 FROM users_0000 WHERE user_id=?");
		) {
			statement.setInt(1, toUserId);
			ResultSet resultSet = statement.executeQuery();
			if (!resultSet.next()) {
				Log.d("存在しないユーザへのwave");
				return false;
			}
		} catch (SQLException throwables) {
			throwables.printStackTrace();
		}

		boolean insertResult = UserWave.insert(fromUserId, toUserId, emoji, ipAddress);
		if (insertResult) {
			message = _TEX.T("IllustV.Wave.SendOK");
		}
		return insertResult;
	}
}
