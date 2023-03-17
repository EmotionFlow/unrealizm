package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public final class ReactionListC {
	public int ownerUserId = -1;
	public int contentId = -1;
	public int lastCommentId = -1;
	public void getParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			ownerUserId = Util.toInt(cRequest.getParameter("UID"));
			contentId = Util.toInt(cRequest.getParameter("CID"));
			lastCommentId = Util.toInt(cRequest.getParameter("SD"));
		}
		catch(Exception ignored) {
			;
		}
	}

	public static class ReactionDetail {
		public String comment;
		public int fromUserId;
		public String fromUserNickname;
		public String fromUserProfile;
		public String fromUserProfileFile;
		public boolean isFollowing;
		public boolean isReplied;
	}

	public int selectMaxGallery = 36;
	public ArrayList<ReactionDetail> reactionDetails = new ArrayList<>();
	public int endId = -1;

	public boolean getResults(CheckLogin checkLogin) {
		if (contentId < 0 || ownerUserId < 0) return false;

		boolean bResult = false;

		try (
			Connection connection = DatabaseUtil.dataSource.getConnection();
			PreparedStatement statement = connection.prepareStatement("""
				WITH followers AS (
					SELECT follow_user_id
					FROM follows_0000
					WHERE user_id=?
				)
				SELECT c.comment_id, c.content_id, c.description, c.user_id from_user_id, u.nickname, u.file_name, u.profile, f.follow_user_id IS NOT NULL following
				FROM comments_0000 c
						 LEFT JOIN users_0000 u ON c.user_id = u.user_id
						 LEFT JOIN followers f ON c.user_id = f.follow_user_id
				WHERE c.content_id=? %s
				ORDER BY c.comment_id DESC LIMIT ?;
				""".formatted(lastCommentId < 0 ? "" : "AND c.comment_id<?"))
			) {

			int idx = 1;
			statement.setInt(idx++, checkLogin.m_nUserId);
			statement.setInt(idx++, contentId);
			if (lastCommentId > 0) {
				statement.setInt(idx++, lastCommentId);
			}
			statement.setInt(idx++, selectMaxGallery);
			ResultSet resultSet = statement.executeQuery();
			while (resultSet.next()) {
				ReactionDetail reactionDetail = new ReactionDetail();
				reactionDetail.comment = resultSet.getString("description");
				reactionDetail.fromUserId = resultSet.getInt("from_user_id");
				reactionDetail.fromUserNickname = resultSet.getString("nickname");
				reactionDetail.fromUserProfile = resultSet.getString("profile");
				reactionDetail.fromUserProfileFile = resultSet.getString("file_name");
				reactionDetail.isFollowing = resultSet.getBoolean("following");
				reactionDetails.add(reactionDetail);
				endId = resultSet.getInt("comment_id");
			}

			bResult = true;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return bResult;
	}

}
