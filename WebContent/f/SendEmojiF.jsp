<%@ page import="jp.pipa.poipiku.settlement.CardSettlement"%>
<%@ page import="jp.pipa.poipiku.settlement.Agent" %>
<%@ page import="jp.pipa.poipiku.settlement.VeritransCardSettlement" %>
<%@ page import="jp.pipa.poipiku.settlement.EpsilonCardSettlement" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class SendEmojiC {
	public final int EMOJI_MAX = 10;

	public final int ERR_NONE = 0;
	public final int ERR_RETRY = -10;
	public final int ERR_INQUIRY = -20;
	public final int ERR_CARD_AUTH = -30;
	public final int ERR_UNKNOWN = -99;

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
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			m_strEmoji		= Common.ToString(request.getParameter("EMJ")).trim();
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nAgentId		= Common.ToInt(request.getParameter("AID"));
			m_strIpAddress	= request.getRemoteAddr();
			m_nAmount		= Common.ToIntN(request.getParameter("AMT"), -1, 10000);
			m_strAgentToken = Common.ToString(request.getParameter("TKN"));
			m_strCardExpire	= Common.ToString(request.getParameter("EXP"));
			m_strCardSecurityCode	= Common.ToString(request.getParameter("SEC"));
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
			strSql = "SELECT users_0000.* FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE open_id<>2 AND content_id=?";
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
				Log.d("max 5 emoji");
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
				cState = cConn.prepareStatement(strSql, Statement.RETURN_GENERATED_KEYS);
				cState.setInt(1, m_nUserId);
				cState.setInt(2, 2); // 売り手はポイピク公式
				cState.setInt(3, COrder.STATUS_INIT);
				cState.setInt(4, m_nAmount);
				cState.executeUpdate();
				cResSet = cState.getGeneratedKeys();
				if(cResSet.next()){
					orderId = cResSet.getInt(1);
					Log.d("orders.id", orderId.toString());
				}
				cResSet.close(); cResSet=null;
				cState.close(); cState=null;

				strSql = "INSERT INTO order_details(" +
						" order_id, content_id, product_name, list_price, amount_paid, quantity)" +
						" VALUES (?, ?, ?, ?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, orderId);
				cState.setInt(2, m_nContentId);
				cState.setString(3, m_strEmoji);
				cState.setInt(4, m_nAmount);
				cState.setInt(5, m_nAmount);
				cState.setInt(6, 1);
				cState.executeUpdate();
				cState.close(); cState=null;

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
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, authorizeResult?COrder.STATUS_SETTLEMENT_OK:COrder.STATUS_SETTLEMENT_NG);
				cState.setString(2, authorizeResult? cardSettlement.getAgentOrderId():null);
				cState.setInt(3, orderId);
				cState.executeUpdate();
				cState.close();cState=null;

				if(!authorizeResult){
					setErrCode(cardSettlement);
					return false;
				}
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
			strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) AND comments_0000.user_id!=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
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
				//Log.d(cNotificationToken.m_strNotificationToken, ""+cNotificationToken.m_nTokenType, ""+nBadgeNum, strTitle, strSubTitle, strBody);
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
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SendEmojiC cResults = new SendEmojiC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, _TEX);
%>{
"result_num" : <%=(bRtn)?1:0%>,
"result" : "<%=CEnc.E(CEmoji.parse(cResults.m_strEmoji))%>",
"error_code" : <%=cResults.m_nErrCode%>
}