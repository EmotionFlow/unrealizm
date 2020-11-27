package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;

import javax.naming.InitialContext;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

import jp.pipa.poipiku.CContent;
import jp.pipa.poipiku.CNotificationToken;
import jp.pipa.poipiku.COrder;
import jp.pipa.poipiku.CUser;
import jp.pipa.poipiku.CheckLogin;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.Emoji;
import jp.pipa.poipiku.ResourceBundleControl;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.settlement.Agent;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.EpsilonCardSettlement;
import jp.pipa.poipiku.settlement.VeritransCardSettlement;
import jp.pipa.poipiku.util.GridUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

public class SendEmojiC {
	public static final int ERR_NONE = 0;
	public static final int ERR_RETRY = -10;
	public static final int ERR_INQUIRY = -20;
	public static final int ERR_CARD_AUTH = -30;
	public static final int ERR_MAX_EMOJI = -40;
	public static final int ERR_UNKNOWN = -99;

	public int m_nContentId = -1;
	public String m_strEmoji = "";
	public int m_nUserId = -1;
	public int m_nAmount = -1;
	public int m_nAgentId = -1;
	public String m_strAgentToken = "";
	public String m_strIpAddress = "";
	public String m_strCardExpire = "";
	public String m_strCardSecurityCode = "";
	public int m_nErrCode = ERR_UNKNOWN;
	public String m_strUserAgent = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			m_strEmoji		= Util.toString(request.getParameter("EMJ")).trim();
			m_nUserId		= Util.toInt(request.getParameter("UID"));
			m_nAgentId		= Util.toInt(request.getParameter("AID"));
			m_strIpAddress	= request.getRemoteAddr();
			m_nAmount		= Util.toIntN(request.getParameter("AMT"), -1, 10000);
			m_strAgentToken = Util.toString(request.getParameter("TKN"));
			m_strCardExpire	= Util.toString(request.getParameter("EXP"));
			m_strCardSecurityCode	= Util.toString(request.getParameter("SEC"));
			m_strUserAgent  = request.getHeader("user-agent");
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}

	public boolean getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		if(!Arrays.asList(Emoji.EMOJI_ALL).contains(m_strEmoji)) {
			Log.d("Invalid Emoji : "+ m_strEmoji);
			return false;
		}
		if(checkLogin.m_bLogin && (m_nUserId != checkLogin.m_nUserId)) return false;	// ログインしてるのにIDが異なる

		boolean bRtn = false;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();
			Class.forName("org.postgresql.Driver");
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// 投稿存在確認(不正アクセス対策) & 対象コンテンツ情報取得
			CUser cTargUser = null;
			CContent cTargContent = null;
			Integer nContentUserId = null;
			strSql = "SELECT * FROM contents_0000 "
					+ "WHERE open_id<>2 AND content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				cTargContent = new CContent(resultSet);
				cTargUser = new CUser();
				cTargUser.m_nUserId = resultSet.getInt("user_id");
				CacheUsers0000.User user = users.getUser(cTargUser.m_nUserId);
				cTargUser.m_nLangId = user.langId;
				cTargUser.m_nReaction = user.reaction;
				nContentUserId = user.userId;
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(cTargUser==null || cTargContent==null) return false;
			if(cTargUser.m_nReaction!=CUser.REACTION_SHOW) return false;


			// max 5 emoji
			int nEmojiNum = 0;
			if(checkLogin.m_bLogin) {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND user_id=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setInt(2, m_nUserId);
			} else {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND ip_address=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setString(2, m_strIpAddress);
			}
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				nEmojiNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(nEmojiNum>=Common.EMOJI_MAX[checkLogin.m_nPremiumId]) {
				m_nErrCode = ERR_MAX_EMOJI;
				return false;
			}

			// 課金
			if(m_nAmount>0){
				// ログインしていないと、課金できない。
				if(!checkLogin.m_bLogin){
					return false;
				}
				// 注文生成
				Integer orderId = null;
				strSql = "INSERT INTO orders(" +
						" customer_id, seller_id, status, payment_total)" +
						" VALUES (?, ?, ?, ?)";
				statement = connection.prepareStatement(strSql, Statement.RETURN_GENERATED_KEYS);
				int idx=1;
				statement.setInt(idx++, m_nUserId);
				statement.setInt(idx++, 2); // 売り手はポイピク公式
				statement.setInt(idx++, COrder.STATUS_INIT);
				statement.setInt(idx++, m_nAmount);
				statement.executeUpdate();
				resultSet = statement.getGeneratedKeys();
				if(resultSet.next()){
					orderId = resultSet.getInt(1);
					Log.d("orders.id", orderId.toString());
				}
				resultSet.close(); resultSet=null;
				statement.close(); statement=null;

				strSql = "INSERT INTO order_details(" +
						" order_id, content_id, content_user_id, product_name, list_price, amount_paid, quantity)" +
						" VALUES (?, ?, ?, ?, ?, ?, ?)";
				statement = connection.prepareStatement(strSql);
				idx=1;
				statement.setInt(idx++, orderId);
				statement.setInt(idx++, m_nContentId);
				statement.setInt(idx++, nContentUserId);
				statement.setString(idx++, m_strEmoji);
				statement.setInt(idx++, m_nAmount);
				statement.setInt(idx++, m_nAmount);
				statement.setInt(idx++, 1);
				statement.executeUpdate();
				statement.close(); statement=null;

				CardSettlement cardSettlement = null;
				if(m_nAgentId == Agent.VERITRANS){
					cardSettlement = new VeritransCardSettlement(
							m_nUserId, m_nContentId, orderId, m_nAmount,
							m_strAgentToken, m_strCardExpire, m_strCardSecurityCode);
				}else if(m_nAgentId==Agent.EPSILON){
					cardSettlement = new EpsilonCardSettlement(
							m_nUserId, m_nContentId, orderId, m_nAmount,
							m_strAgentToken, m_strCardExpire, m_strCardSecurityCode,
							m_strUserAgent);
				}

				boolean authorizeResult = cardSettlement.authorize();

				strSql = "UPDATE orders SET status=?, agency_order_id=?, updated_at=now() WHERE id=?";
				statement = connection.prepareStatement(strSql);
				idx=1;
				statement.setInt(idx++, authorizeResult?COrder.STATUS_SETTLEMENT_OK:COrder.STATUS_SETTLEMENT_NG);
				statement.setString(idx++, authorizeResult? cardSettlement.getAgentOrderId():null);
				statement.setInt(idx++, orderId);
				statement.executeUpdate();
				statement.close();statement=null;

				if(!authorizeResult){
					setErrCode(cardSettlement);
					return false;
				}
			}

			// add new comment
			strSql = "INSERT INTO comments_0000(content_id, description, user_id, to_user_id, ip_address) VALUES(?, ?, ?, ?, ?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.setString(2, m_strEmoji);
			statement.setInt(3, m_nUserId);
			statement.setInt(4, cTargUser.m_nUserId);
			statement.setString(5, m_strIpAddress);
			statement.executeUpdate();
			statement.close();statement=null;

			// update comment_list
			GridUtil.updateCommentsLists(connection, m_nContentId);

			/*
			// 使ってないので一時的にコメントアウト
			// update contents_0000 set contents_0000.comment_num=T1.comment_num from ()as T1 WHERE contents_0000.content_id=T1.content_id
			// update making comment num
			strSql ="UPDATE contents_0000 SET comment_num=(SELECT COUNT(*) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.setInt(2, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;
			*/

			// update making comment num
			// update contents_0000 set contents_0000.people_num=T1.people_num from ()as T1 WHERE contents_0000.content_id=T1.content_id
			strSql ="UPDATE contents_0000 SET people_num=(SELECT COUNT(DISTINCT user_id) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.setInt(2, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			bRtn = true; // 以下実行されなくてもOKを返す

			// お知らせ一覧更新
			// サムネイルタイプの判定
			int contentType = Common.CONTENT_TYPE_IMAGE;
			String infoThumb = "";
			switch(cTargContent.m_nEditorId) {
			case Common.EDITOR_TEXT:
				contentType = Common.CONTENT_TYPE_TEXT;
				infoThumb = cTargContent.m_strDescription;
				break;
			case Common.EDITOR_UPLOAD:
			case Common.EDITOR_PASTE:
			case Common.EDITOR_BASIC_PAINT:
			default:
				contentType = Common.CONTENT_TYPE_IMAGE;
				infoThumb = cTargContent.m_strFileName;
				break;
			}
			// お知らせ一覧に追加
			strSql = "INSERT INTO info_lists(user_id, content_id, content_type, info_type, info_thumb, info_desc) "
					+ "VALUES(?, ?, ?, ?, ?, ?) "
					+ "ON CONFLICT ON CONSTRAINT info_lists_pkey "
					+ "DO UPDATE SET "
					+ "info_desc=(COALESCE(info_lists.info_desc, '') || ?), "
					+ "info_date=CURRENT_TIMESTAMP, "
					+ "badge_num=(info_lists.badge_num+1), "
					+ "had_read=false;";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cTargContent.m_nUserId);
			statement.setInt(2, cTargContent.m_nContentId);
			statement.setInt(3, contentType);
			statement.setInt(4, Common.NOTIFICATION_TYPE_REACTION);
			statement.setString(5, infoThumb);
			statement.setString(6, m_strEmoji);
			statement.setString(7, m_strEmoji);
			statement.executeUpdate();
			statement.close();statement=null;

			// 通知先デバイストークンの取得
			ArrayList<CNotificationToken> cNotificationTokens = new ArrayList<CNotificationToken>();
			strSql = "SELECT * FROM notification_tokens_0000 WHERE user_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cTargUser.m_nUserId);
			resultSet = statement.executeQuery();
			while(resultSet.next()) {
				cNotificationTokens.add(new CNotificationToken(resultSet));
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(cNotificationTokens.isEmpty()) return bRtn;

			// バッジに表示する数を取得
			int nBadgeNum = 0;
			strSql = "SELECT SUM(badge_num) FROM info_lists WHERE user_id=? AND had_read=false";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cTargUser.m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				nBadgeNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 送信文字列
			String strTitle = (cTargUser.m_nLangId==1)?_TEX.TJa("Notification.Reaction.Title"):_TEX.TEn("Notification.Reaction.Title");
			String strSubTitle = "";
			String strBody = (cTargUser.m_nLangId==1)?_TEX.TJa("ActivityList.Message.Comment"):_TEX.TEn("ActivityList.Message.Comment");

			// 通知DB登録
			// 連射しないように同じタイプの未送信の通知を削除
			strSql = "DELETE FROM notification_buffers_0000 WHERE notification_token=? AND notification_type=? AND token_type=?";
			statement = connection.prepareStatement(strSql);
			for(CNotificationToken cNotificationToken : cNotificationTokens) {
				statement.setString(1, cNotificationToken.m_strNotificationToken);
				statement.setInt(2, Common.NOTIFICATION_TYPE_REACTION);
				statement.setInt(3, cNotificationToken.m_nTokenType);
				statement.executeUpdate();
			}
			statement.close();statement=null;
			// 送信用に登録
			strSql = "INSERT INTO notification_buffers_0000(notification_token, notification_type, badge_num, title, sub_title, body, token_type) VALUES(?, ?, ?, ?, ?, ?, ?)";
			statement = connection.prepareStatement(strSql);
			for(CNotificationToken cNotificationToken : cNotificationTokens) {
				statement.setString(1, cNotificationToken.m_strNotificationToken);
				statement.setInt(2, Common.NOTIFICATION_TYPE_REACTION);
				statement.setInt(3, nBadgeNum);
				statement.setString(4, strTitle);
				statement.setString(5, strSubTitle);
				statement.setString(6, strBody);
				statement.setInt(7, cNotificationToken.m_nTokenType);
				statement.executeUpdate();
				//Log.d(cNotificationToken.m_strNotificationToken, ""+cNotificationToken.m_nTokenType, ""+nBadgeNum, strTitle, strSubTitle, strBody);
			}
			statement.close();statement=null;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return bRtn;
	}

	private void setErrCode(CardSettlement cardSettlement) {
		if(cardSettlement.errorKind == CardSettlement.ErrorKind.CardAuth){
			m_nErrCode = ERR_CARD_AUTH;
		}else if(cardSettlement.errorKind == CardSettlement.ErrorKind.Common){
			m_nErrCode = ERR_RETRY;
		}else if(cardSettlement.errorKind == CardSettlement.ErrorKind.NeedInquiry){
			m_nErrCode = ERR_INQUIRY; // 決済されてるかもしれないし、されていないかもしれない。
		}else{
			m_nErrCode = ERR_UNKNOWN;
		}
	}

}
