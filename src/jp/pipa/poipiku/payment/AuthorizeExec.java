package jp.pipa.poipiku.payment;

import jp.pipa.poipiku.util.Log;
import jp.veritrans.tercerog.mdk.ITransaction;
import jp.veritrans.tercerog.mdk.TransactionFactory;
import jp.veritrans.tercerog.mdk.dto.CardAuthorizeRequestDto;
import jp.veritrans.tercerog.mdk.dto.CardAuthorizeResponseDto;

public class AuthorizeExec {
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
    // MDKトークン
    private String token = "";

    private static String createOrderid(int userId, int contentId){
        return String.format("dummy-%d-%d-%d", userId, contentId, System.currentTimeMillis());
    }

    public AuthorizeExec(int _userId, int _contentId, int _amount, String _token){
        userId = _userId;
        contentId = _contentId;
        token = _token;
        orderId = createOrderid(userId, contentId);
        amount = Math.max(_amount, 0);
    }

    public boolean doProcess(){
        if(amount < 0){
            return true;
        }
        if(orderId.isEmpty()){
            return false;
        }
        if(userId<0 || contentId<0){
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

        // ペイメントオプション(支払方法・回数)の設定
        String jpo = null;
        if ("10".equals(jpo1) || "80".equals(jpo1)) {
            jpo = jpo1;
        } else if ("61".equals(jpo1) && jpo2 != null) {
            jpo = jpo1 + "C" + jpo2;
        }
        if (jpo != null) reqDto.setJpo(jpo);

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
}