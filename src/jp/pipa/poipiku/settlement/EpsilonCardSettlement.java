package jp.pipa.poipiku.settlement;

import com.drew.metadata.Age;
import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.settlement.epsilon.*;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class EpsilonCardSettlement extends CardSettlement {

    protected String createOrderId(int userId, int contentId) {
        return String.format("poipiku%d", System.currentTimeMillis());
    }

    private String getAgentUserId(int userId) {
        return String.format("poipiku-%d", userId);
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
            strSql = "SELECT 1 FROM creditcard_tokens WHERE user_id=? AND agent_id=?";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, userId);
            cState.setInt(2, Agent.EPSILON);
            cResSet = cState.executeQuery();
            isFirstSettlement = !cResSet.next();

            cResSet.close();cResSet = null;
            cState.close();cState = null;

            SettlementSendInfo ssi = new SettlementSendInfo();
            ssi.userId = getAgentUserId(userId);
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
                5：3DS処理　（カード会社に接続必要）
                9：システムエラー（パラメータ不足、不正等）
                 */
                Log.d("settlementResultInfo: " + settlementResultInfo.toString());
                if ("1".equals(settlementResultInfo.getResult())) {
                    if (isFirstSettlement) {
                        strSql = "INSERT INTO creditcard_tokens" +
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
                        strSql = "UPDATE creditcard_tokens" +
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
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            if(cResSet!=null){try{cResSet.close();cResSet=null;}catch(Exception ex){;}}
            if(cState!=null){try{cState.close();cState=null;}catch(Exception ex){;}}
            if(cConn!=null){try{cConn.close();cConn=null;}catch(Exception ex){;}}
        }
    }
}