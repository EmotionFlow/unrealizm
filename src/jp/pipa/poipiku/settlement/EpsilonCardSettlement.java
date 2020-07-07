package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.settlement.epsilon.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EpsilonCardSettlement extends CardSettlement {

    protected String createOrderId(int userId, int contentId) {
        return String.format("poipiku%d", System.currentTimeMillis());
    }

//    private String getAgentUserId(int userId) {
//        return String.format("poipiku-%d", userId);
//    }

    private String createAgentUserId(int userId) {
        return String.format("poipiku-%d-%d", userId, System.currentTimeMillis());
    }

    public EpsilonCardSettlement(int _userId, int _contentId, int _poipikuOrderId, int _amount,
                                 String _agentToken, String _cardExpire, String _cardSecurityCode,
                                 String _userAgent) {
        super(_userId, _contentId, _poipikuOrderId, _amount, _agentToken, _cardExpire, _cardSecurityCode, _userAgent);
        agent_id = Agent.EPSILON;
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

    public boolean authorize() {
        Log.d("authorize() enter");
        if (!authorizeCheckBase()) {
            Log.d("authorizeCheckBase() is false");
            return false;
        }

        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        ResultSet cResSet = null;
        String strSql = "";

        try {
            dsPostgres = (DataSource) new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();

            // 初回か登録済かを判定
            boolean isFirstSettlement = true;
            strSql = "SELECT agent_user_id FROM creditcards WHERE user_id=? AND agent_id=? AND del_flg=false";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, userId);
            cState.setInt(2, Agent.EPSILON);
            cResSet = cState.executeQuery();
            String strAgentUserId;
            if(cResSet.next()){
                strAgentUserId = cResSet.getString(1);
                isFirstSettlement = false;
            } else {
                strAgentUserId =  createAgentUserId(userId);
                isFirstSettlement = true;
            }

            cResSet.close();cResSet = null;
            cState.close();cState = null;

            SettlementSendInfo ssi = new SettlementSendInfo();
            ssi.userId = strAgentUserId;
            ssi.userName = "DUMMY";
            ssi.userNameKana = "DUMMY";
            ssi.userMailAdd = "dummy@example.com";
            ssi.itemCode = Integer.toString(poipikuOrderId);
            ssi.itemName = "emoji" + contentId;
            ssi.itemPrice = amount;

            ssi.stCode = "11000-0000-00000";
            ssi.cardStCode = "10";            // 一括払い
            ssi.missionCode = 1;               // 課金区分（一回課金固定）
            ssi.processCode = isFirstSettlement ? 1 : 2; // 初回/登録済み課金
            ssi.userTel = "00000000000";

            if (isFirstSettlement) {
                ssi.securityCheck = 1;
                ssi.token = agentToken;
            } else {
                ssi.securityCheck = null;
                ssi.token = "";
            }

            ssi.orderNumber = createOrderId(userId, contentId);
            ssi.memo1 = "DUMMY";
            ssi.memo2 = "DUMMY";
            ssi.userAgent = userAgent;

            EpsilonSettlement epsilonSettlement = new EpsilonSettlement(ssi);
            SettlementResultInfo settlementResultInfo = epsilonSettlement.execSettlement();
            if (settlementResultInfo != null) {
                /* settlementResultInfo.getResult()
                0：決済NG
                1：決済OK
                5：3DS処理　（カード会社に接続必要）<- 3DS認証は使っていないため、この値は返却されないはず。
                9：システムエラー（パラメータ不足、不正等）
                 */
                String settlementResultCode = settlementResultInfo.getResult();
                Log.d("settlementResultInfo: " + settlementResultCode);
                if ("1".equals(settlementResultCode)) {
                    if (isFirstSettlement) {
                        strSql = "INSERT INTO creditcards" +
                                " (user_id, agent_id, card_expire, security_code, agent_user_id, agent_order_id)" +
                                " VALUES (?, ?, ?, ?, ?, ?)";
                        cState = cConn.prepareStatement(strSql);
                        int idx = 1;
                        cState.setInt(idx++, userId);
                        cState.setInt(idx++, Agent.EPSILON);
                        cState.setString(idx++, cardExpire);
                        cState.setString(idx++, cardSecurityCode);
                        cState.setString(idx++, ssi.userId);
                        cState.setString(idx++, ssi.orderNumber);
                    } else {
                        strSql = "UPDATE creditcards" +
                                " SET updated_at=now(), agent_order_id=?" +
                                " WHERE user_id=? AND agent_id=?";
                        cState = cConn.prepareStatement(strSql);
                        int idx = 1;
                        cState.setString(idx++, ssi.orderNumber);
                        cState.setInt(idx++, userId);
                        cState.setInt(idx++, Agent.EPSILON);
                    }
                    cState.executeUpdate();
                    cState.close();cState = null;
                    cConn.close();cConn = null;
                    errorKind = ErrorKind.None;
                    return true;
                } else {
                    if("0".equals(settlementResultCode)) {
                        Log.d(String.format("決済NG userId=%d, contentId=%d", userId, contentId));
                        Log.d("Code: " + settlementResultInfo.getErrCode());
                        Log.d("Detail: " + settlementResultInfo.getErrDetail());
                        errorKind = ErrorKind.CardAuth;
                    } else if("9".equals(settlementResultCode)) {
                        Log.d(String.format("イプシロンからシステムエラー返却された userId=%d, contentId=%d", userId, contentId));
                        Log.d("Code: " + settlementResultInfo.getErrCode());
                        Log.d("Detail: " + settlementResultInfo.getErrDetail());
                        errorKind = ErrorKind.NeedInquiry;
                    } else {
                        Log.d(String.format("settlementResultCodeが想定外の値 userId=%d, contentId=%d", userId, contentId));
                        Log.d("Code: " + settlementResultInfo.getErrCode());
                        Log.d("Detail: " + settlementResultInfo.getErrDetail());
                        errorKind = ErrorKind.Unknown;
                    }
                    return false;
                }

            } else {
                Log.d(String.format("settlementResultInfo == null, userId=%d, contentId=%d", userId, contentId));
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
}