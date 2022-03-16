package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public final class ReplyEmojiC extends Controller {
	public int contentId = -1;
	public int userId = -1;
	public int commentIdLast = -1;
	public int commentIdOffset = -1;
	public boolean replyAll = false;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			contentId = Util.toInt(request.getParameter("IID"));
			userId		= Util.toInt(request.getParameter("UID"));
			commentIdLast = Util.toInt(request.getParameter("CMTLST"));
			commentIdOffset = Util.toInt(request.getParameter("CMTOFST"));
			if (commentIdLast < 0) {
				replyAll = Util.toBoolean(request.getParameter("ALL"));
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

	public int errorCode = 0;
	public static final int ERR_ALREADY_REPLIED = -1;
	public static final int ERR_OTHER_ERROR = -99;
	public String message = "";
	public boolean getResults(final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
		if(contentId < 0 || userId < 0 || commentIdLast < 0 || commentIdOffset < 0) {
			return false;
		}
		if(checkLogin.m_bLogin && (userId != checkLogin.m_nUserId)){
			Log.d("ログインしているのにUserIdが異なる");
			return false;
		}

		boolean result = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();

			// 投稿存在確認(不正アクセス対策) & 対象コンテンツ情報取得
			CContent cTargContent = null;
			int contentOwnerId = -1;

			connection = DatabaseUtil.dataSource.getConnection();
			sql = "SELECT user_id FROM contents_0000 WHERE content_id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				contentOwnerId = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			if (contentOwnerId != checkLogin.m_nUserId) return false;

			// リアクション対象を検索
			int toUserId = -1;
			int targetCommentId = -1;
			connection = DatabaseUtil.dataSource.getConnection();

			sql = """
				SELECT comment_id, user_id
				FROM comments_0000
				WHERE content_id = ?
				  AND comment_id <= ?
				ORDER BY comment_id DESC
				OFFSET ? LIMIT 1;
				""";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, contentId);
			statement.setInt(2, commentIdLast);
			statement.setInt(3, commentIdOffset);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				targetCommentId = resultSet.getInt(1);
				toUserId = resultSet.getInt(2);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 非ログインユーザー、もしくは退会済みユーザ
			if (toUserId < 1 || users.getUser(toUserId) == null) return true;

			// 返信済み
			if (CommentReply.exists(targetCommentId)) {
				errorCode = ERR_ALREADY_REPLIED;
				message = "ALREADY_REPLIED";
				return false;
			}

			// マイリプライ絵文字
			String myReplyEmoji = Emoji.REPLY_EMOJI_DEFAULT;
			sql = """
                SELECT comment_reply_char
				FROM users_0000
				WHERE user_id = ?
				AND comment_reply_char IS NOT NULL
				AND comment_reply_char <> ''
				""";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, checkLogin.m_nUserId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				myReplyEmoji = resultSet.getString(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// リアクションを返す
			result = CommentReply.insert(targetCommentId, contentId, toUserId, myReplyEmoji);
			if (!result) {
				errorCode = ERR_OTHER_ERROR;
				message = "リプライに失敗した";
				return false;
			}

			result = true; // 以下実行されなくてもOKを返す


		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception ignored){;}
		}
		return result;
	}
}
