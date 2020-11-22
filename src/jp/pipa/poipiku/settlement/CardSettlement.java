package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.util.Log;

public abstract class CardSettlement {
    protected Agent agent = new Agent();
    protected int userId = -1;
    protected int contentId = -1;
    protected String agentToken = null;
    protected String cardExpire = null;
    protected String cardSecurityCode = null;
    protected String userAgent = null;
    public int m_nCreditcardIdToPay = -1;

    public enum BillingCategory {
        Undef,      // 未定義
        OneTime,    // 一回限り
        Monthly     // 毎月課金
    }
    public BillingCategory billingCategory = BillingCategory.Undef;

    public enum ErrorKind {
        None,
        CardAuth,       // カード認証や、センターとの通信に関するエラー。
        NeedInquiry,    // 決済されているか不明なエラー。運営に問い合わせて欲しい。
        Common,         // 共通エラー。
        Exception,      // Javaコード内で例外発生
        Unknown         // 不明。通常ありえない。
    }

    public ErrorKind errorKind = ErrorKind.None;

    // poipiku側管理の取引ID
    protected int poipikuOrderId = -1;

    // 代理店側管理の取引ID
    protected String orderId = "";

    // 金額
    public int amount = 0;
    private final int AMOUNT_MAX = 10000;

    protected String errMsg = "";

    protected abstract String createOrderId(int userId, int contentId);

    public String getErrMsg(){ return errMsg; }
    public String getAgentOrderId(){
        return orderId;
    }

    protected CardSettlement(int _userId){
        userId = _userId;
    }

    protected CardSettlement(int _userId, int _contentId, int _poipikuOrderId, int _amount,
                             String _agentToken, String _cardExpire,
                             String _cardSecurityCode, String _userAgent, BillingCategory _billingCategory){
        userId = _userId;
        contentId = _contentId;
        poipikuOrderId = _poipikuOrderId;
        amount = Math.max(_amount, 0);
        agentToken = _agentToken;
        cardExpire = _cardExpire;
        cardSecurityCode = _cardSecurityCode;
        userAgent = _userAgent;
        billingCategory = _billingCategory;
    }

    protected boolean authorizeCheckBase(){
        if(amount <= 0){
            Log.d("amount <= 0");
            return false;
        }
        if(amount > AMOUNT_MAX){
            Log.d("amount <= AMOUNT_MAX");
            return false;
        }
        if(poipikuOrderId<0){
            Log.d("poipikuOrderId.isEmpty()");
            return false;
        }
        return true;
    }

    public abstract boolean authorize();
    public abstract boolean cancelSubscription(int poipikuOrderId);
}