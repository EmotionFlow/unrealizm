package jp.pipa.poipiku.settlement.epsilon;

public class SettlementResultInfo {
    private String result;
    private String errCode;
    private String errDetail;
    private String memo1;
    private String memo2;
    private String redirect;
    private String transCode;
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
    public String getMemo1() {
        return memo1;
    }
    public void setMemo1(String memo1) {
        this.memo1 = memo1;
    }
    public String getMemo2() {
        return memo2;
    }
    public void setMemo2(String memo2) {
        this.memo2 = memo2;
    }
    public String getRedirect() {
        return redirect;
    }
    public void setRedirect(String redirect) {
        this.redirect = redirect;
    }
    public String getTransCode() {
        return transCode;
    }
    public void setTransCode(String transCode) {
        this.transCode = transCode;
    }

    public String toString(){
        return String.format(
                "result: %s, errCode: %s, errDetail: %s, memo1: %s, memo2: %s, reidrect: %s, transcode: %s",
                result, errCode, errDetail, memo1, memo2, redirect, transCode
        );
    }
}
