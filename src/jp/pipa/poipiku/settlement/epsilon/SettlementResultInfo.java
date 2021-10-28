package jp.pipa.poipiku.settlement.epsilon;

public class SettlementResultInfo {
	public String result;
	public String errCode;
	public String errDetail;
	public String memo1;
	public String memo2;
	public String redirect;
	public String transCode;

	public String toString(){
		return String.format(
				"result: %s, errCode: %s, errDetail: %s, memo1: %s, memo2: %s, reidrect: %s, transcode: %s",
				result, errCode, errDetail, memo1, memo2, redirect, transCode
		);
	}
}
