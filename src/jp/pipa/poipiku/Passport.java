package jp.pipa.poipiku;

import java.sql.*;
import java.time.LocalDateTime;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.settlement.CardSettlement;
import jp.pipa.poipiku.settlement.EpsilonCardSettlement;
import jp.pipa.poipiku.util.Log;


public class Passport {
    public static final int ERR_NONE = 0;
    public static final int ERR_RETRY = -10;
    public static final int ERR_INQUIRY = -20;
    public static final int ERR_CARD_AUTH = -30;
    public static final int ERR_UNKNOWN = -99;

    public int m_nUserId = -1;
    public int m_nPassportId = -1;
    public int m_nOrderId = -1;
    public Timestamp m_tsSubscription = null;
    public Timestamp m_tsRelease = null;

    public Boolean m_bCancellationHistory = null;
    public enum Status {
        Undef,      // 非ログインユーザーなど
        NotMember,  // パスポートなし
        Billing,    // 購入中、支払期間中、会員有効
        Cancelling  // 解禁解除申し込み中、会員有効、次月月初にはNotMemberになる。
        //FreePeriod, // 購入中、無償期間中、会員有効
    }
    public Status m_status = Status.Undef;

    public Passport(CheckLogin checkLogin) {
        if(checkLogin == null || !checkLogin.m_bLogin) return;

        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        ResultSet cResSet = null;
        String strSql = "";

        try {
            Class.forName("org.postgresql.Driver");
            dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();

            strSql = "SELECT * FROM passport_logs WHERE user_id=? ORDER BY subscription_datetime DESC LIMIT 2";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, checkLogin.m_nUserId);
            cResSet = cState.executeQuery();

            if(cResSet.next()){
                m_nOrderId = cResSet.getInt("order_id");
                m_tsSubscription = cResSet.getTimestamp("subscription_datetime");
                m_tsRelease = cResSet.getTimestamp("cancel_datetime");

                // 1レコードだけだったら初回申込、
                // 2レコードあったら、「初回申込ではない」とする。
                m_bCancellationHistory = !cResSet.next();
            } else {
                m_bCancellationHistory = false;
            }

        } catch(Exception e) {
            Log.d(strSql);
            e.printStackTrace();
        } finally {
            try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
            try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
            try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
        }

        m_nUserId = checkLogin.m_nUserId;
        m_nPassportId = checkLogin.m_nPassportId;
        setStatus();
    }

    public boolean buy(int nPassportId, String strAgentToken, String strCardExpire,
                       String strCardSecurityCode, String strUserAgent) {
        if(m_status==Status.Undef){
            Log.d("m_status==Status.Undef");
            return false;
        }
        if(m_nPassportId==nPassportId){
            Log.d("m_nPassportId==nPassportId");
            return false;
        }
        if(nPassportId<=0){
            Log.d("nPassportId<=0");
            return false;
        }

        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        ResultSet cResSet = null;
        String strSql = "";

        try {
            Class.forName("org.postgresql.Driver");
            dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();

            int nProductId = -1;
            int nProdCatId = -1;
            String strProdName = null;
            int nListPrice = -1;
            strSql = "SELECT prod.id, prod.category_id, prod.name, prod.list_price FROM passports AS pass" +
                    " INNER JOIN products AS prod ON pass.product_id=prod.id" +
                    " WHERE pass.id=?;";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, nPassportId);
            cResSet = cState.executeQuery();

            if(cResSet.next()){
                nProductId = cResSet.getInt(1);
                nProdCatId = cResSet.getInt(2);
                strProdName = cResSet.getString(3);
                nListPrice = cResSet.getInt(4);
            }else{
                Log.d("不正なpassport_id");
                return false;
            }
            cResSet.close();
            cState.close();

            strSql = "SELECT 1 FROM passport_logs WHERE user_id=? AND cancel_datetime IS NULL LIMIT 1";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, m_nUserId);
            cResSet = cState.executeQuery();
            if(cResSet.next()){
                Log.d("二重に契約しようとした:" + m_nUserId);
                return false;
            }
            cResSet.close();
            cState.close();


            // 注文生成
            Integer orderId = null;
            // 売り手はポイピク公式固定、cheer_statusは-1:非分配対象固定。
            strSql = "INSERT INTO orders(" +
                    " customer_id, seller_id, status, payment_total, cheer_point_status)" +
                    " VALUES (?, 2, ?, ?, -1)";
            cState = cConn.prepareStatement(strSql, Statement.RETURN_GENERATED_KEYS);
            int idx=1;
            cState.setInt(idx++, m_nUserId);            // customre_id
            cState.setInt(idx++, COrder.STATUS_INIT);   // status
            cState.setInt(idx++, nListPrice);           // payment_total
            cState.executeUpdate();
            cResSet = cState.getGeneratedKeys();
            if(cResSet.next()){
                orderId = cResSet.getInt(1);
                Log.d("orders.id", orderId.toString());
            }
            cResSet.close(); cResSet=null;
            cState.close(); cState=null;

            // 商品種別は2:ポイパス固定、数量は1固定。
            strSql = "INSERT INTO order_details(" +
                    " order_id, content_id, content_user_id, product_id, product_category_id, product_name, list_price, amount_paid, quantity)" +
                    " VALUES (?, NULL, NULL, ?, ?, ?, ?, ?, 1)";
            cState = cConn.prepareStatement(strSql);
            idx=1;
            cState.setInt(idx++, orderId);          // order_id
            cState.setInt(idx++, nProductId);       // product_id
            cState.setInt(idx++, nProdCatId);       // product_category_id
            cState.setString(idx++, strProdName);   // product_name
            cState.setInt(idx++, nListPrice);       // list_price
            cState.setInt(idx++, nListPrice);       // amount_paid
            cState.executeUpdate();
            cState.close(); cState=null;

            CardSettlement cardSettlement = new EpsilonCardSettlement(
                    m_nUserId,
                    -1,
                    orderId,
                    nListPrice,
                    strAgentToken,
                    strCardExpire,
                    strCardSecurityCode,
                    strUserAgent,
                    CardSettlement.BillingCategory.Monthly);
            boolean authorizeResult = cardSettlement.authorize();
            if (!authorizeResult) {
                Log.d("cardSettlement.authorize() failed.");
                return false;
            }
            final int nCreditCardId = cardSettlement.m_nCreditcardIdToPay;

            //// begin transaction
            cConn.setAutoCommit(false);

            // insert into passport_logs
            strSql = "INSERT INTO passport_logs(user_id, subscription_datetime, cancel_datetime, order_id) VALUES (?, current_timestamp, null, ?)";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, m_nUserId);
            cState.setInt (2, orderId);
            cState.executeUpdate();

            // update users_0000
            strSql = "UPDATE users_0000 SET passport_id=? WHERE user_id=?";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, nPassportId);
            cState.setInt(2, m_nUserId);
            cState.executeUpdate();

            // update orders
            strSql = "UPDATE orders SET creditcard_id=?, status=?, agency_order_id=?, updated_at=now() WHERE id=?";
            cState = cConn.prepareStatement(strSql);
            idx=1;
            cState.setInt(idx++, nCreditCardId);
            cState.setInt(idx++, authorizeResult?COrder.STATUS_SETTLEMENT_OK:COrder.STATUS_SETTLEMENT_NG);
            cState.setString(idx++, authorizeResult? cardSettlement.getAgentOrderId():null);
            cState.setInt(idx++, orderId);
            cState.executeUpdate();

            cConn.commit();
            cConn.setAutoCommit(true);

            cState.close();cState=null;

            //// end transaction

            CacheUsers0000.getInstance().clearUser(m_nUserId);

        } catch(Exception e) {
            Log.d(strSql);
            e.printStackTrace();
        } finally {
            try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
            try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
            try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
        }


        return true;
    }

    public boolean cancel() {
        if(m_tsRelease != null){
            Log.d("解約済み");
            return false;
        }

        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        String strSql = "";

        try {
            // 定期課金キャンセル
            CardSettlement cardSettlement = new EpsilonCardSettlement(m_nUserId);
            boolean authorizeResult = cardSettlement.cancelSubscription(m_nOrderId);
            if (!authorizeResult) {
                Log.d("cardSettlement.authorize() failed.");
                return false;
            }

            // update passport_logs
            Class.forName("org.postgresql.Driver");
            dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();
            strSql = "UPDATE passport_logs SET cancel_datetime=current_timestamp WHERE user_id=? AND order_id=?";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, m_nUserId);
            cState.setInt(2, m_nOrderId);
            cState.executeUpdate();
            cState.close();cState=null;
            cConn.close();cConn=null;

            /* users_0000は月末までそのまま。月初にスクリプトで更新 */

        } catch(Exception e) {
            Log.d(strSql);
            e.printStackTrace();
        } finally {
            try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
            try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
        }

        return true;
    }

    private void setStatus(){
        if (m_nUserId<0) {
            m_status = Status.Undef;
            return;
        }

        if (m_nPassportId <= 0) {
            m_status = Status.NotMember;
        } else {
            if (m_tsRelease != null) {
                m_status = Status.Cancelling;
            } else {
                m_status = Status.Billing;
//                LocalDateTime d = LocalDateTime.now();
//                final int nowYear = d.getYear();
//                final int nowMonth = d.getMonthValue();
//                final int sbscYear = m_tsSubscription.toLocalDateTime().getYear();
//                final int sbscMonth = m_tsSubscription.toLocalDateTime().getDayOfMonth();
//                if (!m_bCancellationHistory && nowYear == sbscYear && nowMonth == sbscMonth) {
//                    m_status = Status.FreePeriod;
//                } else {
//                    m_status = Status.Billing;
//                }
            }
        }
    }
}
