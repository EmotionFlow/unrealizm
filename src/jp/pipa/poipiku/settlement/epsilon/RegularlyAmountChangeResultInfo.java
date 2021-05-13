package jp.pipa.poipiku.settlement.epsilon;

public class RegularlyAmountChangeResultInfo {
	private String result;
	private String errCode;
	private String errDetail;
	private String userId;
	private String itemCode;
	private String itemPrice;
	private String missionCode;
	public String getResult() {
		return result;
	}
	public void setResult(String result) {
		this.result = result;
	}
	public String getErrCode() {
		return errCode;
	}
	public void setErrCode(String errCode) {
		this.errCode = errCode;
	}
	public String getErrDetail() {
		return errDetail;
	}
	public void setErrDetail(String errDetail) {
		this.errDetail = errDetail;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getItemCode() {
		return itemCode;
	}
	public void setItemCode(String itemCode) {
		this.itemCode = itemCode;
	}
	public String getItemPrice() {
		return itemPrice;
	}
	public void setItemPrice(String itemPrice) {
		this.itemPrice = itemPrice;
	}
	public String getMissionCode() {
		return missionCode;
	}
	public void setMissionCode(String missionCode) {
		this.missionCode = missionCode;
	}

	public String toString(){
		return String.format(
				"result: %s, errCode: %s, errDetail: %s, userId: %s, itemCode: %s, itemPrice: %s, missionCode: %s",
				result, errCode, errDetail, userId, itemCode, itemPrice, missionCode
		);
	}
}
