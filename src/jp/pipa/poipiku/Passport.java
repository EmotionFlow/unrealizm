package jp.pipa.poipiku;

import java.sql.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;

import jp.pipa.poipiku.util.Log;


public class Passport {
    public int m_nUserId = -1;
    public int m_nPassportId = -1;
    public Timestamp m_tsSubscription = null;
    public Timestamp m_tsRelease = null;
    private Boolean m_bFirstTime = null;

    public enum Status {
        Undef, NotMember, FreePeriod, Billing, UnBilling
    }
    public Status m_status = Status.Undef;

    public Passport(CheckLogin checkLogin) {
        if (checkLogin == null || !checkLogin.m_bLogin) return;

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
                m_tsSubscription = cResSet.getTimestamp("subscription_datetime");
                m_tsRelease = cResSet.getTimestamp("release_datetime");

                // 1レコードだけだったら初回申込。2レコードあったら、「初回申込ではない」とする。
                m_bFirstTime = !cResSet.next();
            } else {
                m_bFirstTime = null;
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
        m_nPassportId = checkLogin.m_nPremiumMemberId;
        setStatus();
    }

    private void setStatus(){
        if (m_nUserId<0) {
            m_status = Status.Undef;
            return;
        }

        // パスポートなし
        if (m_nPassportId == 0) {
            m_status = Status.NotMember;
            return;
        }

        // 初月無料期間中

        // 課金中

        // 課金解除申込中

    }

}
