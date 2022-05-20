package jp.pipa.poipiku.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.notify.EmojiNotifier;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.CardSettlementEpsilon;
import jp.pipa.poipiku.util.DatabaseUtil;
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
			String remoteAddr = request.getRemoteAddr();
			if (remoteAddr != null && !remoteAddr.isEmpty()) {
				if (remoteAddr.length() > 16) {
					m_strIpAddress	= remoteAddr.substring(0, 16);
				} else {
					m_strIpAddress	= remoteAddr;
				}
			}
			m_nAmount		= Util.toIntN(request.getParameter("AMT"), -1, 10000);
			m_strAgentToken = Util.toString(request.getParameter("TKN"));
			m_strCardExpire	= Util.toString(request.getParameter("EXP"));
			m_strCardSecurityCode	= Util.toString(request.getParameter("SEC"));
			m_strUserAgent  = request.getHeader("user-agent");
		} catch(Exception e) {
			e.printStackTrace();
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}

	public boolean getResults(final CheckLogin checkLogin, final ResourceBundleControl _TEX) {
		if(!Arrays.asList(Emoji.EMOJI_ALL).contains(m_strEmoji)) {
			Log.d("Invalid Emoji : "+ m_strEmoji);
			return false;
		}
		if(checkLogin.m_bLogin && (m_nUserId != checkLogin.m_nUserId)){
			Log.d("ログインしているのにUserIdが異なる");
			return false;
		}

		boolean bRtn = false;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			CacheUsers0000 users  = CacheUsers0000.getInstance();

			// 投稿存在確認(不正アクセス対策) & 対象コンテンツ情報取得
			CUser cTargUser = null;
			CContent cTargContent = null;
			Integer nContentUserId = null;

			connection = DatabaseUtil.dataSource.getConnection();
			strSql = "SELECT * FROM contents_0000 WHERE content_id=? AND open_id<>2";
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
			if(nEmojiNum>=Common.EMOJI_MAX[checkLogin.m_nPassportId]) {
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
				Order order = new Order();
				order.customerId = m_nUserId;
				order.sellerId = 2; // ポイピク公式
				order.paymentTotal = m_nAmount;
				order.cheerPointStatus = Order.CheerPointStatus.BeforeDistribute;
				if (order.insert() != 0 || order.id < 0) {
					throw new Exception("insert order error");
				}

				OrderDetail orderDetail = new OrderDetail();
				orderDetail.orderId = order.id;
				orderDetail.contentId = m_nContentId;
				orderDetail.productCategory = OrderDetail.ProductCategory.Pochibukuro;
				orderDetail.contentUserId = nContentUserId;
				orderDetail.productName = m_strEmoji;
				orderDetail.listPrice = m_nAmount;
				orderDetail.amountPaid = m_nAmount;
				orderDetail.quantity = 1;
				if (orderDetail.insert() != 0 || orderDetail.id < 0) {
					throw new Exception("insert order_detail error");
				}

				CardSettlement cardSettlement = new CardSettlementEpsilon(m_nUserId);
				cardSettlement.contentId = m_nContentId;
				cardSettlement.poipikuOrderId = order.id;
				cardSettlement.amount = m_nAmount;
				cardSettlement.agentToken = m_strAgentToken;
				cardSettlement.cardExpire = m_strCardExpire;
				cardSettlement.cardSecurityCode = m_strCardSecurityCode;
				cardSettlement.userAgent = m_strUserAgent;
				cardSettlement.billingCategory = CardSettlement.BillingCategory.OneTime;
				cardSettlement.itemName = CardSettlement.ItemName.Emoji;

				boolean authorizeResult = cardSettlement.authorize();

				order.update(
						authorizeResult ? Order.Status.SettlementOk : Order.Status.SettlementError,
						authorizeResult ? cardSettlement.getAgentOrderId() : null,
						authorizeResult ? cardSettlement.creditCardIdToPay : null);

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
			GridUtil.updateCommentsLists(connection, m_nContentId, cTargUser.m_nUserId);

			// update making comment num
			strSql ="UPDATE contents_0000 SET people_num=(SELECT COUNT(DISTINCT user_id) FROM comments_0000 WHERE content_id=?) WHERE content_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, m_nContentId);
			statement.setInt(2, m_nContentId);
			statement.executeUpdate();
			statement.close();statement=null;

			bRtn = true; // 以下実行されなくてもOKを返す

			// お知らせ一覧更新
			// サムネイルタイプの判定
			final int contentType;
			final String infoThumb;
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

			EmojiNotifier notifier = new EmojiNotifier();
			notifier.notifyReactionReceived(
					cTargContent.m_nUserId,
					cTargContent.m_nContentId,
					contentType,
					m_strEmoji,
					infoThumb
					);
			
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.setAutoCommit(true);connection.close();connection=null;}}catch(Exception ignored){;}
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
