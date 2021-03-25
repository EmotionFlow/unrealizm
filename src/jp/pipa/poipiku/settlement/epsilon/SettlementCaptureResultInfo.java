package jp.pipa.poipiku.settlement.epsilon;

public class SettlementCaptureResultInfo {
	private String result;
	private String errCode;
	private String errDetail;
	public String getResult() {
		return result;
	}
	public void setResult(String result) {
		this.result = result;
	}
	public String getErrCode() {
		return errCode!=null?errCode:"";
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

	public String toString(){
		return String.format(
				"result: %s, errCode: %s, errDetail: %s",
				result, errCode, errDetail
		);
	}
}
