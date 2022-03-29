package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Emoji;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public final class GetMyReplyEmojiC extends Controller{
	public int userId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("ID"));
		} catch(Exception ignored) {
			;
		}
	}

	public String myReplyEmoji = Emoji.REPLY_EMOJI_DEFAULT;
	public boolean getResults(final CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != userId){
			Log.d("login error");
			return false;
		}

		boolean result = false;
		final String sql = """
			SELECT chars
			FROM comment_templates
			WHERE user_id=? AND disp_order=0
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			) {
			statement.setInt(1, userId);
			ResultSet resultSet = statement.executeQuery();
			if (resultSet.next()) {
				myReplyEmoji = resultSet.getString(1);
			}
			result = true;
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return result;
	}
}
