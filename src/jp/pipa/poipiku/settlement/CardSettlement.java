package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.util.Log;

public abstract class CardSettlement {
	protected Agent agent = new Agent();
	protected int poipikuUserId = -1;
	public int contentId = -1;
	public int requestId = -1;
	public String agentToken = null;
	public String cardExpire = null;
	public String cardSecurityCode = null;
	public String userAgent = null;
	public int creditcardIdToPay = -1;

	public enum ItemName {
		Emoji, Poipass, Request, Gift
	}
	public ItemName itemName = ItemName.Emoji;
	protected String getItemNameStr() {
		final String s;
		switch (itemName) {
			case Emoji:
				s = "emoji" + contentId;
				break;
			case Poipass:
				s = "poipass";
				break;
			case Request:
				s = "request";
				break;
			case Gift:
				s = "gift";
				break;
			default:
				s = "";
		}
		return s;
	}

	public enum BillingCategory {
		Undef,	  // 未定義
		OneTime,	// 一回限り
		Monthly,	 // 毎月課金
		MonthlyFirstFree, // 毎月課金、登録月無料
		AuthorizeOnly // 仮売上
	}
	public BillingCategory billingCategory = BillingCategory.Undef;

	public enum ErrorKind {
		None,
		CardAuth,	   // カード認証や、センターとの通信に関するエラー。
		NeedInquiry,	// 決済されているか不明なエラー。運営に問い合わせて欲しい。
		Common,		 // 共通エラー。
		Exception,	  // Javaコード内で例外発生
		Unknown		 // 不明。通常ありえない。
	}

	public ErrorKind errorKind = ErrorKind.None;

	// poipiku側管理の取引ID
	public int poipikuOrderId = -1;

	// 代理店側管理の取引ID
	public String orderId = "";

	// 金額
	public int amount = 0;
	private static final int AMOUNT_MAX = 15000;

	protected String errMsg = "";

	protected abstract String createOrderId(int userId, int contentId);

	public String getErrMsg(){ return errMsg; }
	public String getAgentOrderId(){
		return orderId;
	}

	protected CardSettlement(int _userId){
		poipikuUserId = _userId;
	}

	protected boolean authorizeCheckBase(){
		if(amount <= 0){
			Log.d("amount <= 0");
			return false;
		}
		if(amount > AMOUNT_MAX){
			Log.d("amount > AMOUNT_MAX");
			return false;
		}
		if(poipikuOrderId<0){
			Log.d("poipikuOrderId.isEmpty()");
			return false;
		}
		return true;
	}

	public abstract boolean authorize();
	public abstract boolean capture(int poipikuOrderId);
	public abstract boolean cancelSubscription(int poipikuOrderId);
	public abstract boolean changeRegularlyAmount(int amount);
	public abstract String changeCreditCardInfo();
}
