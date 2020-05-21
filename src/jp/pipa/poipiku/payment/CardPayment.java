package jp.pipa.poipiku.payment;

import jp.pipa.poipiku.util.Log;
import jp.veritrans.tercerog.mdk.ITransaction;
import jp.veritrans.tercerog.mdk.TransactionFactory;
import jp.veritrans.tercerog.mdk.dto.CardAuthorizeRequestDto;
import jp.veritrans.tercerog.mdk.dto.CardAuthorizeResponseDto;
import jp.veritrans.tercerog.mdk.dto.CardReAuthorizeRequestDto;
import jp.veritrans.tercerog.mdk.dto.CardReAuthorizeResponseDto;

public class CardPayment {
    private int userId = -1;
    private int contentId = -1;

    // 与信方法　与信売上(与信と同時に売上処理も行います)固定
    private final String withCapture = "1";
    // 取引ID
    private String orderId = "";
    // 金額
    public int amount = 0;
    // 支払方法 一括払い固定
    private final String jpo1 = "10";
    // 支払回数 一括払いなので設定不要
    private final String jpo2 = "";

    private static String createOrderid(int userId, int contentId){
        return String.format("dummy-%d-%d-%d", userId, contentId, System.currentTimeMillis());
    }

    public String getAgencyOrderId(){
        return orderId;
    }

    public CardPayment(int _userId, int _contentId, int _amount){
        userId = _userId;
        contentId = _contentId;
        orderId = createOrderid(userId, contentId);
        amount = Math.max(_amount, 0);
    }

    private boolean authorizeCheckBase(){
        if(amount <= 0){
            return false;
        }
        if(orderId.isEmpty()){
            return false;
        }
        if(userId<0 || contentId<0){
            return false;
        }
        return true;
    }

    public boolean authorize(String token){
        if(!authorizeCheckBase()){
            return false;
        }
        if(token.isEmpty()){
            return false;
        }

        boolean ret = false;
        // +++++++++++++++++++++++++++++++++++++++++++++++++++++
        // 要求DTOを生成し、値を設定します。
        // +++++++++++++++++++++++++++++++++++++++++++++++++++++
        CardAuthorizeRequestDto reqDto = new CardAuthorizeRequestDto();

        reqDto.setOrderId(orderId);
        reqDto.setAmount(Integer.toString(amount, 10));
        reqDto.setToken(token);

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
            ret = true;
        } catch (Exception ex) {
            ex.printStackTrace();
            Log.d("PAYMENT mErrMsg", "Exception Occured : " + ex.getMessage());
            ret = false;
        }
        return ret;
    }

    public boolean reAuthorize(String authorizedOrderId, String cardExpire, String cardSecurityCode){
        if(!authorizeCheckBase()){
            return false;
        }
        if(authorizedOrderId==null || authorizedOrderId.isEmpty()){
            return false;
        }
        if(cardExpire==null || cardExpire.isEmpty()){
            return false;
        }
        if(cardSecurityCode==null || cardSecurityCode.isEmpty()){
            return false;
        }

        boolean ret = false;

        CardReAuthorizeRequestDto reqDto = new CardReAuthorizeRequestDto();
        // 取引IDの設定
        reqDto.setOrderId(orderId);
        // 元取引ID(再与信対象)の設定
        reqDto.setOriginalOrderId(authorizedOrderId);
        // 与信方法の設定
        reqDto.setWithCapture("true");
        // 金額の設定
        reqDto.setAmount(Integer.toString(amount, 10));
        // ペイメントオプション(支払方法・回数)の設定
        reqDto.setJpo("10");
        // セキュリティコード設定
        reqDto.setSecurityCode(cardSecurityCode);

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