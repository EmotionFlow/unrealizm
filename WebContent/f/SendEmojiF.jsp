<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendEmojiC {
	public int EMOJI_MAX = 10;

	public int m_nContentId = -1;
	public String m_strEmoji = "";
	public int m_nUserId = -1;
	public String m_strIpAddress = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_strEmoji		= Common.ToString(request.getParameter("EMJ")).trim();
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_strIpAddress	= request.getRemoteAddr();
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		if(!Arrays.asList(Common.EMOJI_LIST[Common.EMOJI_CAT_ALL]).contains(m_strEmoji)) {
			Log.d("Invalid Emoji : "+ m_strEmoji);
			return false;
		}
		if(checkLogin.m_bLogin && (m_nUserId != checkLogin.m_nUserId)) return false;	// ログインしてるのにIDが異なる

		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// 投稿存在確認(不正アクセス対策)
			CUser cTargUser = null;
			strSql = "SELECT users_0000.* FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cTargUser = new CUser();
				cTargUser.m_nUserId = cResSet.getInt("user_id");
				cTargUser.m_nLangId = cResSet.getInt("lang_id");
				cTargUser.m_nReaction = cResSet.getInt("ng_reaction");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cTargUser==null) return false;
			if(cTargUser.m_nReaction!=CUser.REACTION_SHOW) return false;


			// max 5 emoji
			int nEmojiNum = 0;
			if(checkLogin.m_bLogin) {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND user_id=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cState.setInt(2, m_nUserId);
				cResSet = cState.executeQuery();
			} else {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND ip_address=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nContentId);
				cState.setString(2, m_strIpAddress);
				cResSet = cState.executeQuery();
			}
			if(cResSet.next()) {
				nEmojiNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(nEmojiNum>=EMOJI_MAX) {
				return false;
			}

			// add new comment
			strSql = "INSERT INTO comments_0000(content_id, description, user_id, ip_address) VALUES(?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setString(2, m_strEmoji);
			cState.setInt(3, m_nUserId);
			cState.setString(4, m_strIpAddress);
			cState.executeUpdate();
			cState.close();cState=null;

			/*
			// 使ってないので一時的にコメントアウト
			// update contents_0000 set contents_0000.comment_num=T1.comment_num from ()as T1 WHERE contents_0000.content_id=T1.content_id
			// update making comment num
			strSql ="UPDATE contents_0000 SET comment_num=(SELECT COUNT(*) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setInt(2, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;
			*/

			// update making comment num
			// update contents_0000 set contents_0000.people_num=T1.people_num from ()as T1 WHERE contents_0000.content_id=T1.content_id
			strSql ="UPDATE contents_0000 SET people_num=(SELECT COUNT(DISTINCT user_id) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cState.setInt(2, m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			bRtn = true; // 以下実行されなくてもOKを返す

			// 通知
			/*
			// オンラインの場合は何もしない
			if(CheckLogin.isOnline(cTargUser.m_nUserId)) return bRtn;
			*/

			// 通知先デバイストークンの取得
			ArrayList<CNotificationToken> cNotificationTokens = new ArrayList<CNotificationToken>();
			strSql = "SELECT * FROM notification_tokens_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cTargUser.m_nUserId);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				cNotificationTokens.add(new CNotificationToken(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(cNotificationTokens.isEmpty()) return bRtn;

			// バッジに表示する数を取得
			int nBadgeNum = 0;
			strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND comments_0000.user_id!=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cTargUser.m_nUserId);
			cState.setInt(2, cTargUser.m_nUserId);
			cState.setInt(3, cTargUser.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				nBadgeNum = cResSet.getInt(1);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// 送信文字列
			String strTitle = (cTargUser.m_nLangId==1)?_TEX.TJa("Notification.Reaction.Title"):_TEX.TEn("Notification.Reaction.Title");
			String strSubTitle = "";
			String strBody = (cTargUser.m_nLangId==1)?_TEX.TJa("Notification.Reaction.Body"):_TEX.TEn("Notification.Reaction.Body");

			// 通知DB登録
			// 連射しないように同じタイプの未送信の通知を削除
			strSql = "DELETE FROM notification_buffers_0000 WHERE notification_token=? AND notification_type=? AND token_type=?";
			cState = cConn.prepareStatement(strSql);
			for(CNotificationToken cNotificationToken : cNotificationTokens) {
				cState.setString(1, cNotificationToken.m_strNotificationToken);
				cState.setInt(2, Common.NOTIFICATION_TYPE_REACTION);
				cState.setInt(3, cNotificationToken.m_nTokenType);
				cState.executeUpdate();
			}
			cState.close();cState=null;
			// 送信
			strSql = "INSERT INTO notification_buffers_0000(notification_token, notification_type, badge_num, title, sub_title, body, token_type) VALUES(?, ?, ?, ?, ?, ?, ?)";
			cState = cConn.prepareStatement(strSql);
			for(CNotificationToken cNotificationToken : cNotificationTokens) {
				cState.setString(1, cNotificationToken.m_strNotificationToken);
				cState.setInt(2, Common.NOTIFICATION_TYPE_REACTION);
				cState.setInt(3, nBadgeNum);
				cState.setString(4, strTitle);
				cState.setString(5, strSubTitle);
				cState.setString(6, strBody);
				cState.setInt(7, cNotificationToken.m_nTokenType);
				cState.executeUpdate();
				Log.d(cNotificationToken.m_strNotificationToken, ""+cNotificationToken.m_nTokenType, ""+nBadgeNum, strTitle, strSubTitle, strBody);
			}
			cState.close();cState=null;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SendEmojiC cResults = new SendEmojiC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, _TEX);
%>{
"result_num" : <%=(bRtn)?1:0%>,
"result" : "<%=CEnc.E(CEmoji.parse(cResults.m_strEmoji))%>"
}