package jp.pipa.poipiku.settlement.epsilon;

public class SettlementCaptureSendInfo {
	public String orderNumber;
	public Integer sales_amount;

	public String characterCode;
	public Integer version;
	public Integer xml;

	public SettlementCaptureSendInfo(){
		xml = 1;
		version = 2;
		characterCode = "UTF-8";
	}
}
