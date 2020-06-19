package jp.pipa.poipiku.payment;

import jp.pipa.poipiku.util.Log;

public abstract class CardPayment {
    protected int agency_id = -1;
    protected int userId = -1;
    protected int contentId = -1;
    protected String agencyToken = null;
    protected String cardExpire = null;
    protected String cardSecurityCode = null;


    public enum ErrorKind {
        None,
        CardAuth,       // カード認証や、センターとの通信に関するエラー。
        NeedInquiry,    // 決済されているか不明なエラー。運営に問い合わせて欲しい。
        Common,         // 共通エラー。
        Exception,      // Javaコード内で例外発生
        Unknown         // 不明。通常ありえない。
    }

    public ErrorKind errorKind = ErrorKind.None;

    // 取引ID
    protected String orderId = "";
    // 金額
    public int amount = 0;

    protected String errMsg = "";

    protected abstract String createOrderId(int userId, int contentId);

    public String getErrMsg(){ return errMsg; }
    public String getAgencyOrderId(){
        return orderId;
    }

    protected CardPayment(int _userId, int _contentId, int _amount,
                          String _agencyToken, String _cardExpire, String _cardSecurityCode){
        userId = _userId;
        contentId = _contentId;
        orderId = createOrderId(userId, contentId);
        amount = Math.max(_amount, 0);
        agencyToken = _agencyToken;
        cardExpire = _cardExpire;
        cardSecurityCode = _cardSecurityCode;
    }

    protected boolean authorizeCheckBase(){
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

    protected abstract boolean authorize();
}