<%@ page import="jp.pipa.poipiku.settlement.CardSettlement"%>
<%@ page import="jp.pipa.poipiku.settlement.Agent" %>
<%@ page import="jp.pipa.poipiku.settlement.VeritransCardSettlement" %>
<%@ page import="jp.pipa.poipiku.settlement.EpsilonCardSettlement" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class SendEmojiC {
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
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			// 投稿存在確認(不正アクセス対策)
			CUser cTargUser = null;
			Integer nContentUserId = null;
			strSql = "SELECT u.user_id, u.lang_id, u.ng_reaction, c.user_id content_user_id FROM contents_0000 AS c INNER JOIN users_0000 AS u ON c.user_id=u.user_id WHERE open_id<>2 AND content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			resultSet = statement.executeQuery();
			if(resultSet.next()) {
				cTargUser = new CUser();
				cTargUser.m_nUserId = resultSet.getInt("user_id");
				cTargUser.m_nLangId = resultSet.getInt("lang_id");
				cTargUser.m_nReaction = resultSet.getInt("ng_reaction");
				nContentUserId = resultSet.getInt("content_user_id");
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(cTargUser==null) return false;
			if(cTargUser.m_nReaction!=CUser.REACTION_SHOW) return false;


			// max 5 emoji
			int nEmojiNum = 0;
			if(checkLogin.m_bLogin) {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND user_id=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setInt(2, m_nUserId);
				resultSet = statement.executeQuery();
			} else {
				strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id=? AND ip_address=? AND upload_date > CURRENT_TIMESTAMP-interval'1day'";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, m_nContentId);
				statement.setString(2, m_strIpAddress);
				resultSet = statement.executeQuery();
			}
			if(resultSet.next()) {
				nEmojiNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;
			if(nEmojiNum>=Common.EMOJI_MAX[checkLogin.m_nPremiumId]) {
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
			strSql = "INSERT INTO comments_0000(content_id, description, user_id, ip_address) VALUES(?, ?, ?, ?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.setString(2, m_strEmoji);
			statement.setInt(3, m_nUserId);
			statement.setString(4, m_strIpAddress);
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

			// 通知
			/*
			// オンラインの場合は何もしない
			if(CheckLogin.isOnline(cTargUser.m_nUserId)) return bRtn;
			*/

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
			strSql = "SELECT COUNT(*) FROM comments_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE open_id<>2 AND user_id=?) AND comments_0000.user_id!=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, cTargUser.m_nUserId);
			statement.setInt(2, cTargUser.m_nUserId);
			statement.setInt(3, cTargUser.m_nUserId);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				nBadgeNum = resultSet.getInt(1);
			}
			resultSet.close();resultSet=null;
			statement.close();statement=null;

			// 送信文字列
			String strTitle = (cTargUser.m_nLangId==1)?_TEX.TJa("Notification.Reaction.Title"):_TEX.TEn("Notification.Reaction.Title");
			String strSubTitle = "";
			String strBody = (cTargUser.m_nLangId==1)?_TEX.TJa("Notification.Reaction.Body"):_TEX.TEn("Notification.Reaction.Body");

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
			// 送信
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
}%>
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