package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EpsilonCartSettlement extends CartSettlement {

    protected String createOrderId(int userId, int contentId){
        return String.format("poipiku-%d-%d-%d", userId, contentId, System.currentTimeMillis());
    }

    public EpsilonCartSettlement(int _userId, int _contentId, int _amount,
                                 String _agentToken, String _cardExpire, String _cardSecurityCode){
        super(_userId, _contentId, _amount, _agentToken, _cardExpire, _cardSecurityCode);
        agent_id = Agent.EPSILON;
    }

    public boolean authorize(){
        if(!authorizeCheckBase()){
            return false;
        }

        if(agentToken ==null){
            return newAuthorize();
        } else {
            return reAuthorize();
        }
    }

    private boolean newAuthorize(){
        if(agentToken.isEmpty()){
            return false;
        }

        boolean ret = false;
        // +++++++++++++++++++++++++++++++++++++++++++++++++++++
        // 要求DTOを生成し、値を設定します。
        // +++++++++++++++++++++++++++++++++++++++++++++++++++++
        CardAuthorizeRequestDto reqDto = new CardAuthorizeRequestDto();
        orderId = createOrderId(userId, contentId);
        reqDto.setOrderId(orderId);
        reqDto.setAmount(Integer.toString(amount, 10));
        reqDto.setToken(agentToken);

        // ペイメントオプション(支払方法・回数)の設定　一括払い固定
        reqDto.setJpo("10");

        // 与信方法によって、売上フラグを設定
        if ("1".equals(withCapture)) reqDto.setWithCapture("true");

        try {
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++
            // コマンドを実行し、応答DTOを取得します。
            // +++++++++++++++++++++++++++++++++++++++++++++++++++++
            ITransaction tran = TransactionFactory.getInstance(reqDto);
            CardAuthorizeResponseDto resDto = (CardAuthorizeResponseDto) tran.execute();

            Log.d("PAYMENT orderId", resDto.getOrderId());
            Log.d("PAYMENT mStatus", resDto.getMstatus());
            Log.d("PAYMENT mErrMsg", resDto.getMerrMsg());
            Log.d("PAYMENT vResultCode", resDto.getVResultCode());
            Log.d("PAYMENT reqCardNumber", resDto.getReqCardNumber());
            Log.d("PAYMENT resAuthCode", resDto.getResAuthCode());

            if(resDto.getMstatus().equals(STATUS_SUCCESS) && resDto.getVResultCode().equals(RESULTCODE_SUCCESS)){
                ret = true;
            } else {
                ret = false;
                errMsg = resDto.getMerrMsg();
                char headChar = resDto.getVResultCode().charAt(0);
                switch(headChar){
                    case 'A':
                        errorKind = ErrorKind.CardAuth;
                        break;
                    case 'M':
                        // TODO 本来はslackなどで運営に即通知したい
                        errorKind = ErrorKind.NeedInquiry;
                        break;
                    case 'N':
                    case 'O':
                        errorKind = ErrorKind.Common;
                        break;
                    default:
                        errorKind = ErrorKind.Unknown;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            Log.d("PAYMENT mErrMsg", "Exception Occured : " + ex.getMessage());
            errMsg = ex.getMessage();
            errorKind = ErrorKind.Exception;
            ret = false;
        }

        if(ret){
            DataSource dsPostgres = null;
            Connection cConn = null;
            PreparedStatement cState = null;
            String strSql = "";

            try{
                strSql = "INSERT INTO" +
                        " creditcard_tokens(user_id, expire, security_code, authorized_order_id, agent_id)" +
                        " VALUES (?, ?, ?, ?, ?)";
                cState = cConn.prepareStatement(strSql);
                cState.setInt(1, userId);
                cState.setString(2, cardExpire);
                cState.setString(3, cardSecurityCode);
                cState.setString(4, orderId);
                cState.setInt(5, agent_id);
                cState.executeUpdate();
                cState.close(); cState=null;
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
                try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
            }

        }

        return ret;
    }

    private boolean reAuthorize(){
        DataSource dsPostgres = null;
        Connection cConn = null;
        PreparedStatement cState = null;
        ResultSet cResSet = null;
        String strSql = "";

        String expire = "";
        String securityCode = "";
        String authOrderId = "";

        try {
            dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
            cConn = dsPostgres.getConnection();

            strSql = "SELECT expire, security_code, authorized_order_id FROM creditcard_tokens WHERE user_id=?";
            cState = cConn.prepareStatement(strSql);
            cState.setInt(1, userId);
            cResSet = cState.executeQuery();

            if(cResSet.next()){
                expire = cResSet.getString("expire");
                securityCode = cResSet.getString("security_code");
                authOrderId = cResSet.getString("authorized_order_id");
            }else{
                Log.d("与信済みの決済情報が見つからない(uid)", userId);
                errorKind = ErrorKind.Common;
                return false;
            }
            cResSet.close();cResSet=null;
            cState.close();cState=null;
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
            try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
            try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
        }

        if(authOrderId==null || authOrderId.isEmpty()){
            return false;
        }
        if(expire==null || expire.isEmpty()){
            return false;
        }
        if(securityCode==null || securityCode.isEmpty()){
            return false;
        }

        boolean ret = false;

        CardReAuthorizeRequestDto reqDto = new CardReAuthorizeRequestDto();
        // 取引IDの設定
        reqDto.setOrderId(orderId);
        // 元取引ID(再与信対象)の設定
        reqDto.setOriginalOrderId(authOrderId);
        // 与信方法の設定
        reqDto.setWithCapture("true");
        // 金額の設定
        reqDto.setAmount(Integer.toString(amount, 10));
        // ペイメントオプション(支払方法・回数)の設定
        reqDto.setJpo("10");
        // セキュリティコード設定
        reqDto.setSecurityCode(securityCode);

        ITransaction tran = null;
        CardReAuthorizeResponseDto resDto = null;

        try {
            tran = TransactionFactory.getInstance(reqDto);
            resDto = (CardReAuthorizeResponseDto) tran.execute();

            // リクエストとレスポンスを実行コンソール上で表示する
            Log.d("PAYMENT *- Card(ReAuthorize) -*");
            Log.d("PAYMENT << RESPONSE >>");
            Log.d("PAYMENT orderId", resDto.getOrderId());
            Log.d("PAYMENT Status", resDto.getMstatus());
            Log.d("PAYMENT Message", resDto.getMerrMsg());
            Log.d("PAYMENT Result Code", resDto.getVResultCode());
            Log.d("PAYMENT Auth Code", resDto.getResAuthCode());
            Log.d("PAYMENT Reference Number", resDto.getResReturnReferenceNumber());
            ret = true;
        } catch (Exception ex) {
            Log.d("PAYMENT Exception Occured !");
            Log.d("PAYMENT Exception Message" + ex.getMessage());
            ret = false;
        }

        return ret;
    }
}