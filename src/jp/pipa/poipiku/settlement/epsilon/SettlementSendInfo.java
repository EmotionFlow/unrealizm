package jp.pipa.poipiku.settlement.epsilon;

public class SettlementSendInfo {
	public String userId;
	public String userName;
	public String userMailAdd;
	public String itemCode;
	public String itemName;
	public String orderNumber;
	public String stCode;
	public String cardStCode;
	public Integer missionCode;
	public Integer itemPrice;
	public Integer processCode;
	public String userTel;
	public String userNameKana;
	public Integer conveniCode;
	public String memo1;
	public String memo2;
	public String characterCode;
	public Integer version;
	public Integer xml;

	public String deliveryCode;
	public String consigneePostal;
	public String consigneeName;
	public String consigneeAddress;
	public String consigneeTel;
	public String ordererPostal;
	public String ordererName;
	public String ordererAddress;
	public String ordererTel;

	public Integer securityCheck;
	public String token;
	public String userAgent;

	public SettlementSendInfo(){
		xml = 1;
		version = 2;
		characterCode = "UTF-8";
		conveniCode = 0;
		deliveryCode = "99";
	}
}
