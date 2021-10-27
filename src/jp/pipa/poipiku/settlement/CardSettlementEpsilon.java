package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.settlement.epsilon.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CardSettlementEpsilon extends CardSettlement {
	// 半角英数字 32byte 注文単位でユニークに設定してください。
	protected String createOrderId(int userId, int contentId) {
		return String.format("poi%dT%d", userId, System.currentTimeMillis());
	}

	// 半角英数字.-+/@ 64byte以下
	private String createAgentUserId(int userId) {
		return String.format("poi-%d-%d", userId, System.currentTimeMillis());
	}

	public CardSettlementEpsilon(int _userId){
		super(_userId);
		agent.id = Agent.EPSILON;
	}

	@Override
	protected boolean authorizeCheckBase() {
		if(userAgent==null || userAgent.isEmpty()){
			Log.d("userAgent==null || userAgent.isEmpty()");
			return false;
		} else {
			return super.authorizeCheckBase();
		}
	}

	public boolean cancelSubscription(int poipikuOrderId) {
		Log.d("cancelSubscription() enter");
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		boolean result = false;

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// EPSILON側user_id取得。
			strSql = "SELECT c.agent_user_id FROM creditcards c INNER JOIN orders o ON c.id=o.creditcard_id WHERE o.id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, poipikuOrderId);
			cResSet = cState.executeQuery();
			String strAgentUserId="";
			if(cResSet.next()){
				strAgentUserId = cResSet.getString(1);
			} else {
				Log.d("EPSILON user_idが取得できない：" + poipikuOrderId);
			}
			cResSet.close();cResSet = null;
			cState.close();cState = null;
			cConn.close();cConn = null;

			SettlementCancelSendInfo cancelSendInfo = new SettlementCancelSendInfo();

			cancelSendInfo.userId = strAgentUserId;

			// epsilonの商品コード=ポイピクのorder_id
			cancelSendInfo.itemCode = Integer.toString(poipikuOrderId);

			EpsilonSettlementCancel epsilonSettlementCancel = new EpsilonSettlementCancel(poipikuUserId, cancelSendInfo);
			SettlementCancelResultInfo resultInfo = epsilonSettlementCancel.execCancel();

			if (resultInfo != null) {
				// resultInfo.result 1:解除OK 9:解除NG
				if ("1".equals(resultInfo.result)) {
					Log.d("解除OK");
					result = true;
				} else if ("9".equals(resultInfo.result)) {
					Log.d("解除NG");
					Log.d(resultInfo.errCode);
					Log.d(resultInfo.errDetail);

					// 解除NGの理由がすでに解除処理中または解除済みの定期課金に対する解除だったら、result=trueとする。
					// errCodeに識別可能な値が入ってこないので、detailの文字列で判定している。
					result = resultInfo.errDetail.equals("既に解除処理中です") || resultInfo.errDetail.equals("既に解除済です");
				} else {
					Log.d("EPSILONから想定外のresult: " + resultInfo.result);
					result = false;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.Exception;
			result = false;
		} finally {
			if(cResSet!=null){try{cResSet.close();cResSet=null;}catch(Exception ex){;}}
			if(cState!=null){try{cState.close();cState=null;}catch(Exception ex){;}}
			if(cConn!=null){try{cConn.close();cConn=null;}catch(Exception ex){;}}
		}

		return result;
	}

	private SettlementSendInfo createSettlementSendInfo(boolean isFirstSettlement, String strAgentUserId) {
		SettlementSendInfo ssi = new SettlementSendInfo();
		ssi.userId = strAgentUserId;
		ssi.userName = "DUMMY";
		ssi.userNameKana = "DUMMY";
		ssi.userMailAdd = "dummy@example.com";
		ssi.itemCode = Integer.toString(poipikuOrderId);
		ssi.itemPrice = amount;

		ssi.stCode = "11000-0000-00000";
		ssi.cardStCode = "10";			 // 一括払い

		// 課金区分
		switch (billingCategory) {
			// 一度払い
			case OneTime:
				ssi.missionCode = 1;
				ssi.kariFlag = null;    // 仮・実売上は管理画面の設定に従う
				break;
			// 定期課金（毎月）
			case Monthly:
				ssi.missionCode = 21;
				ssi.kariFlag = null;    // 仮・実売上は管理画面の設定に従う
				break;
			case MonthlyFirstFree:
				ssi.missionCode = 23;
				ssi.kariFlag = null;
				break;
			case AuthorizeOnly:
				ssi.missionCode = 1;
				ssi.kariFlag = 1;       // 仮売上固定
				break;
			default:
				ssi.missionCode = -1;
		}
		ssi.itemName = getItemNameStr();

		ssi.processCode = isFirstSettlement ? 1 : 2; // 初回/登録済み課金
		ssi.userTel = "00000000000";

		if (isFirstSettlement) {
			ssi.securityCheck = 1;
			ssi.token = agentToken;
		} else {
			ssi.securityCheck = null;
			ssi.token = "";
		}

		ssi.orderNumber = createOrderId(poipikuUserId, contentId);
		orderId = ssi.orderNumber;
		ssi.memo1 = "DUMMY";
		ssi.memo2 = "DUMMY";
		ssi.userAgent = userAgent;
		return ssi;
	}

	public boolean authorize() {
		if (!authorizeCheckBase()) {
			Log.d("authorizeCheckBase() is false");
			return false;
		}

		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// 初回か登録済かを判定、EPSILON側user_id取得。
			boolean isFirstSettlement = true;
			strSql = "SELECT agent_user_id FROM creditcards WHERE user_id=? AND agent_id=? AND del_flg=false";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, poipikuUserId);
			cState.setInt(2, agent.id);
			cResSet = cState.executeQuery();
			String strAgentUserId;
			if(cResSet.next()){
				strAgentUserId = cResSet.getString(1);
				isFirstSettlement = false;
			} else {
				strAgentUserId =  createAgentUserId(poipikuUserId);
				isFirstSettlement = true;
			}
			cResSet.close();cResSet = null;
			cState.close();cState = null;
			// この後の決済処理に時間がかかり、connectionがcloseされたりされなかったりなので、
			// ここで明示的にcloseする。
			cConn.close();cConn = null;

			SettlementSendInfo ssi = createSettlementSendInfo(isFirstSettlement, strAgentUserId);

			EpsilonSettlementAuthorize epsilonSettlementAuthorize = new EpsilonSettlementAuthorize(poipikuUserId, ssi);

			// epsilon側の都合で時間のかかる決済処理
			SettlementResultInfo settlementResultInfo = epsilonSettlementAuthorize.execSettlement();

			if (settlementResultInfo != null) {
				/* settlementResultInfo.getResult()
				0：決済NG
				1：決済OK
				5：3DS処理　（カード会社に接続必要）<- 3DS認証は使っていないため、この値は返却されないはず。
				9：システムエラー（パラメータ不足、不正等）
				 */
				String settlementResultCode = settlementResultInfo.result;
				Log.d("settlementResultInfo: " + settlementResultCode);
				if ("1".equals(settlementResultCode)) {
					cConn = DatabaseUtil.dataSource.getConnection();
					if (isFirstSettlement) {
						strSql = "INSERT INTO creditcards" +
								" (user_id, agent_id, card_expire, security_code, agent_user_id, last_agent_order_id)" +
								" VALUES (?, ?, ?, ?, ?, ?) RETURNING id";
						cState = cConn.prepareStatement(strSql);
						int idx = 1;
						cState.setInt(idx++, poipikuUserId);
						cState.setInt(idx++, Agent.EPSILON);
						cState.setString(idx++, cardExpire);
						cState.setString(idx++, cardSecurityCode);
						cState.setString(idx++, ssi.userId);
						cState.setString(idx++, ssi.orderNumber);
						cResSet = cState.executeQuery();
						if(cResSet.next()) {
							creditcardIdToPay = cResSet.getInt(1);
							Log.d("m_nCreditcardIdToPay: " + creditcardIdToPay);
						}
						cResSet.close();cResSet=null;
					} else {
						strSql = "SELECT id FROM creditcards WHERE user_id=? AND agent_id=? AND del_flg=false";
						cState = cConn.prepareStatement(strSql);
						cState.setInt(1, poipikuUserId);
						cState.setInt(2, agent.id);
						cResSet = cState.executeQuery();
						if(cResSet.next()) {
							creditcardIdToPay = cResSet.getInt("id");
							Log.d("m_nCreditcardIdToPay: " + creditcardIdToPay);
						}
						cResSet.close();cResSet=null;

						strSql = "UPDATE creditcards" +
								" SET updated_at=now(), last_agent_order_id=?" +
								" WHERE id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, ssi.orderNumber);
						cState.setInt(2, creditcardIdToPay);
						cState.executeUpdate();
					}
					cState.close();cState = null;
					cConn.close();cConn = null;
					errorKind = ErrorKind.None;
					return true;
				} else {
					if("0".equals(settlementResultCode)) {
						Log.d(String.format("決済NG userId=%d, contentId=%d", poipikuUserId, contentId));
						Log.d("Code: " + settlementResultInfo.errCode);
						Log.d("Detail: " + settlementResultInfo.errDetail);
						errorKind = ErrorKind.CardAuth;
					} else if("9".equals(settlementResultCode)) {
						Log.d(String.format("イプシロンからシステムエラー返却された userId=%d, contentId=%d", poipikuUserId, contentId));
						Log.d("Code: " + settlementResultInfo.errCode);
						Log.d("Detail: " + settlementResultInfo.errDetail);
						errorKind = ErrorKind.NeedInquiry;
					} else {
						Log.d(String.format("settlementResultCodeが想定外の値 userId=%d, contentId=%d", poipikuUserId, contentId));
						Log.d("Code: " + settlementResultInfo.errCode);
						Log.d("Detail: " + settlementResultInfo.errDetail);
						errorKind = ErrorKind.Unknown;
					}
					return false;
				}

			} else {
				Log.d(String.format("settlementResultInfo == null, userId=%d, contentId=%d", poipikuUserId, contentId));
				errorKind = ErrorKind.Unknown;
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.Exception;
			return false;
		} finally {
			if(cResSet!=null){try{cResSet.close();cResSet=null;}catch(Exception ex){;}}
			if(cState!=null){try{cState.close();cState=null;}catch(Exception ex){;}}
			if(cConn!=null){try{cConn.close();cConn=null;}catch(Exception ex){;}}
		}
	}


	public boolean capture(int poipikuOrderId) {
		Log.d("capture() enter");
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";
		boolean result = false;

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			// EPSILON側order_number(注文番号)取得。
			sql = "SELECT agency_order_id, payment_total FROM orders WHERE id=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, poipikuOrderId);
			resultSet = statement.executeQuery();
			String agentOrderId="";
			int amount = 0;
			if(resultSet.next()){
				agentOrderId = resultSet.getString(1);
				amount = resultSet.getInt(2);
			} else {
				Log.d("EPSILON user_idが取得できない：" + poipikuOrderId);
			}
			resultSet.close();resultSet = null;
			statement.close();statement = null;
			connection.close();connection = null;

			SettlementCaptureSendInfo sendInfo = new SettlementCaptureSendInfo();
			sendInfo.orderNumber = agentOrderId;
			sendInfo.sales_amount = amount;

			EpsilonSettlementCapture capture = new EpsilonSettlementCapture(poipikuUserId, sendInfo);
			SettlementCaptureResultInfo resultInfo = capture.execSettlement();

			if (resultInfo != null) {
				/* resultInfo.getResult()
				1：実売上OK
				9：実売上NG
				 */
				String resultCode = resultInfo.getResult();
				Log.d("resultInfo: " + resultCode);
				if ("1".equals(resultCode)) {
					return true;
				} else {
					Log.d(String.format("実売上処理でエラーが発生 requestId=%d", requestId));
					Log.d("Code: " + resultInfo.getErrCode());
					Log.d("Detail: " + resultInfo.getErrDetail());
					errorKind = ErrorKind.CardAuth;
					return false;
				}
			} else {
				Log.d(String.format("resultInfoが想定外の値 requestId=%d", requestId));
				Log.d("Code: " + resultInfo.getErrCode());
				Log.d("Detail: " + resultInfo.getErrDetail());
				errorKind = ErrorKind.Unknown;
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.Exception;
			return false;
		} finally {
			if(resultSet!=null){try{resultSet.close();resultSet=null;}catch(Exception ignored){;}}
			if(statement!=null){try{statement.close();statement=null;}catch(Exception ignored){;}}
			if(connection!=null){try{connection.close();connection=null;}catch(Exception ignored){;}}
		}
	}

	public boolean changeRegularlyAmount(int amount) {
		// epsilon側のuser_id, item_code検索
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		String itemCode = null;
		String epsilonUserId = null;
		try {
			connection = DatabaseUtil.dataSource.getConnection();
		
			sql = "SELECT orders.id, agent_user_id" +
					" FROM orders" +
					"   INNER JOIN passport_subscriptions ps ON orders.id = ps.order_id" +
					"   INNER JOIN creditcards c ON orders.creditcard_id = c.id" +
					" WHERE ps.user_id = ?" +
					"   AND agent_id = ?" +
					"   AND orders.del_flg = FALSE" +
					"   AND c.del_flg = FALSE" +
					" ORDER BY orders.created_at DESC" +
					" LIMIT 1";
			Log.d(sql);
			statement = connection.prepareStatement(sql);
			statement.setInt(1, poipikuUserId);
			statement.setInt(2, Agent.EPSILON);
			resultSet = statement.executeQuery();
			if (resultSet.next()) {
				itemCode = String.valueOf(resultSet.getInt(1));
				epsilonUserId = resultSet.getString(2);
			}
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.Exception;
			return false;
		} finally {
			if(resultSet!=null){try{resultSet.close();resultSet=null;}catch(Exception ignored){;}}
			if(statement!=null){try{statement.close();statement=null;}catch(Exception ignored){;}}
			if(connection!=null){try{connection.close();connection=null;}catch(Exception ignored){;}}
		}

		// 金額変更CGIを叩く
		EpsilonRegularlyAmountChange cmd = new EpsilonRegularlyAmountChange(poipikuUserId);
		RegularlyAmountChangeSendInfo sendInfo = new RegularlyAmountChangeSendInfo();
		sendInfo.userId = epsilonUserId;
		sendInfo.itemCode = itemCode;
		sendInfo.itemPrice = amount;
		RegularlyAmountChangeResultInfo resultInfo = cmd.execAmountChange(sendInfo);

		if (resultInfo != null) {
			/* resultInfo.getResult()
			1：金額変更OK
			9：金額変更NG
			 */
			String resultCode = resultInfo.getResult();
			Log.d("resultInfo: " + resultCode);
			if ("1".equals(resultCode)) {
				return true;
			} else {
				Log.d(String.format("金額変更処理でエラーが発生 requestId=%d", requestId));
				Log.d("Code: " + resultInfo.getErrCode());
				Log.d("Detail: " + resultInfo.getErrDetail());
				errorKind = ErrorKind.CardAuth;
				return false;
			}
		} else {
			Log.d(String.format("金額変更処理でresultInfoが想定外の値 requestId=%d", requestId));
			Log.d("Code: " + resultInfo.getErrCode());
			Log.d("Detail: " + resultInfo.getErrDetail());
			errorKind = ErrorKind.Unknown;
			return false;
		}
	}

	public String changeCreditCardInfo() {
		Log.d("changeCreditCardInfo() enter");
		String redirectUrl = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";
		boolean result = false;

		try {
			cConn = DatabaseUtil.dataSource.getConnection();

			// EPSILON側user_id取得。
			strSql = "SELECT c.agent_user_id FROM creditcards c WHERE user_id=? AND del_flg=false";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, poipikuUserId);
			cResSet = cState.executeQuery();
			String agentUserId="";
			if(cResSet.next()){
				agentUserId = cResSet.getString(1);
			} else {
				Log.d("EPSILON user_idが取得できない：" + poipikuOrderId);
			}
			cResSet.close();cResSet = null;
			cState.close();cState = null;
			cConn.close();cConn = null;

			SettlementSendInfo sendInfo = new SettlementSendInfo();
			sendInfo.userId = agentUserId;
			sendInfo.stCode = "10000-0000-00000";
			sendInfo.processCode = 4;
			sendInfo.memo1 = "poipiku";
			sendInfo.memo2 = Integer.toString(poipikuUserId);

			EpsilonSettlementAuthorize authorize = new EpsilonSettlementAuthorize(poipikuUserId, sendInfo);
			SettlementResultInfo resultInfo = authorize.execSettlement();

			if (resultInfo != null) {
				/* resultInfo.result
					1:成功 0:失敗
				 */
				if ("1".equals(resultInfo.result)) {
					Log.d("カード情報変更要求成功");
					redirectUrl = resultInfo.redirect;
				} else if ("0".equals(resultInfo.result)) {
					Log.d("カード情報変更要求失敗");
					Log.d(resultInfo.errCode);
					Log.d(resultInfo.errDetail);
				} else {
					Log.d("EPSILONから想定外のresult: " + resultInfo.result);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			errorKind = ErrorKind.Exception;
		} finally {
			if(cResSet!=null){try{cResSet.close();cResSet=null;}catch(Exception ex){;}}
			if(cState!=null){try{cState.close();cState=null;}catch(Exception ex){;}}
			if(cConn!=null){try{cConn.close();cConn=null;}catch(Exception ex){;}}
		}

		return redirectUrl;
	}
}
