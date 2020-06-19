package jp.pipa.poipiku.payment.epsilon;

import java.util.Map;

public class Config {
    private Map<String,String> getsales_url;
    private Map<String,String> regulary_url;
    private String order_url;
    private String getsales_type;
    private String contract_code;
    private String password;
    private String memo1;
    private String memo2;
    private String item_code;
    private String notify_file;
    private String deferred_file;
    private String notify_responce;
    private String st_code;

    public Map<String, String> getGetsales_url() {
        return getsales_url;
    }
    public void setGetsales_url(Map<String, String> getsales_url) {
        this.getsales_url = getsales_url;
    }
    public Map<String, String> getRegulary_url() {
        return regulary_url;
    }
    public void setRegulary_url(Map<String, String> regulary_url) {
        this.regulary_url = regulary_url;
    }
    public String getGetsales_type() {
        return getsales_type;
    }
    public void setGetsales_type(String getsales_type) {
        this.getsales_type = getsales_type;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getOrder_url() {
        return order_url;
    }
    public void setOrder_url(String order_url) {
        this.order_url = order_url;
    }
    public String getContract_code() {
        return contract_code;
    }
    public void setContract_code(String contract_code) {
        this.contract_code = contract_code;
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
    public String getItem_code() {
        return item_code;
    }
    public void setItem_code(String item_code) {
        this.item_code = item_code;
    }
    public String getNotify_file() {
        return notify_file;
    }
    public void setNotify_file(String notify_file) {
        this.notify_file = notify_file;
    }
    public String getDeferred_file() {
        return deferred_file;
    }
    public void setDeferred_file(String deferred_file) {
        this.deferred_file = deferred_file;
    }
    public String getNotify_responce() {
        return notify_responce;
    }
    public void setNotify_responce(String notify_responce) {
        this.notify_responce = notify_responce;
    }
    public String getSt_code() {
        return st_code;
    }
    public void setSt_code(String st_code) {
        this.st_code = st_code;
    }
}
