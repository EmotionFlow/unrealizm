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
import java.util.ArrayList;
import java.util.List;

public class GetReplyEmojiListC extends Controller{
	public int userId = -1;
	public int contentId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId = Util.toInt(request.getParameter("ID"));
			contentId = Util.toInt(request.getParameter("TD"));
		} catch(Exception ignored) {
			;
		}
	}

	public List<String> getResults(final CheckLogin checkLogin) {
		if (!checkLogin.m_bLogin || checkLogin.m_nUserId != userId){
			Log.d("login error");
			return null;
		}

		List<String> replies = new ArrayList<>();
		final var sql = """
			SELECT description
			FROM comment_replies
			WHERE content_id=? AND to_user_id=? ORDER BY id DESC
			""";
		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement(sql);
			) {
			statement.setInt(1, contentId);
			statement.setInt(2, userId);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				replies.add(resultSet.getString(1));
			}
		} catch(SQLException e) {
			Log.d(sql);
			e.printStackTrace();
		}
		return replies;
	}
}
