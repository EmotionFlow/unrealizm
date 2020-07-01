package jp.pipa.poipiku.settlement.epsilon;

public class SettlementSendInfo {
    private String contractCode;
    private String userId;
    private String userName;
    private String userMailAdd;
    private String itemCode;
    private String itemName;
    private String orderNumber;
    private String stCode;
    private Integer missionCode;
    private Integer itemPrice;
    private Integer processCode;
    private String userTel;
    private String userNameKana;
    private Integer conveniCode;
    private String memo1;
    private String memo2;
    private String characterCode;
    private Integer version;
    private Integer xml;

    private String deliveryCode;
    private String consigneePostal;
    private String consigneeName;
    private String consigneeAddress;
    private String consigneeTel;
    private String ordererPostal;
    private String ordererName;
    private String ordererAddress;
    private String ordererTel;

    public String getContractCode() {
        return contractCode;
    }
    public void setContractCode(String contractCode) {
        this.contractCode = contractCode;
    }
    public String getUserId() {
        return userId;
    }
    public void setUserId(String userId) {
        this.userId = userId;
    }
    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }
    public String getUserMailAdd() {
        return userMailAdd;
    }
    public void setUserMailAdd(String userMailAdd) {
        this.userMailAdd = userMailAdd;
    }
    public String getItemCode() {
        return itemCode;
    }
    public void setItemCode(String itemCode) {
        this.itemCode = itemCode;
    }
    public String getItemName() {
        return itemName;
    }
    public void setItemName(String itemName) {
        this.itemName = itemName;
    }
    public String getOrderNumber() {
        return orderNumber;
    }
    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }
    public String getStCode() {
        return stCode;
    }
    public void setStCode(String stCode) {
        this.stCode = stCode;
    }
    public Integer getMissionCode() {
        return missionCode;
    }
    public void setMissionCode(Integer missionCode) {
        this.missionCode = missionCode;
    }
    public Integer getItemPrice() {
        return itemPrice;
    }
    public void setItemPrice(Integer itemPrice) {
        this.itemPrice = itemPrice;
    }
    public Integer getProcessCode() {
        return processCode;
    }
    public void setProcessCode(Integer processCode) {
        this.processCode = processCode;
    }
    public String getUserTel() {
        return userTel;
    }
    public void setUserTel(String userTel) {
        this.userTel = userTel;
    }
    public String getUserNameKana() {
        return userNameKana;
    }
    public void setUserNameKana(String userNameKana) {
        this.userNameKana = userNameKana;
    }
    public Integer getConveniCode() {
        return conveniCode;
    }
    public void setConveniCode(Integer conveniCode) {
        this.conveniCode = conveniCode;
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
    public String getCharacterCode() {
        return characterCode;
    }
    public void setCharacterCode(String charset) {
        this.characterCode = charset;
    }
    public Integer getVersion() {
        return version;
    }
    public void setVersion(Integer version) {
        this.version = version;
    }
    public Integer getXml() {
        return xml;
    }
    // コンストラクタ
    public void setXml(Integer xml) {
        this.xml = xml;
    }
    public String getDeliveryCode() {
        return deliveryCode;
    }
    public void setDeliveryCode(String deliveryCode) {
        this.deliveryCode = deliveryCode;
    }
    public String getConsigneePostal() {
        return consigneePostal;
    }
    public void setConsigneePostal(String consigneePostal) {
        this.consigneePostal = consigneePostal;
    }
    public String getConsigneeName() {
        return consigneeName;
    }
    public void setConsigneeName(String consigneeName) {
        this.consigneeName = consigneeName;
    }
    public String getConsigneeAddress() {
        return consigneeAddress;
    }
    public void setConsigneeAddress(String consigneeAddress) {
        this.consigneeAddress = consigneeAddress;
    }
    public String getConsigneeTel() {
        return consigneeTel;
    }
    public void setConsigneeTel(String consigneeTel) {
        this.consigneeTel = consigneeTel;
    }
    public String getOrdererPostal() {
        return ordererPostal;
    }
    public void setOrdererPostal(String ordererPostal) {
        this.ordererPostal = ordererPostal;
    }
    public String getOrdererName() {
        return ordererName;
    }
    public void setOrdererName(String ordererName) {
        this.ordererName = ordererName;
    }
    public String getOrdererAddress() {
        return ordererAddress;
    }
    public void setOrdererAddress(String ordererAddress) {
        this.ordererAddress = ordererAddress;
    }
    public String getOrdererTel() {
        return ordererTel;
    }
    public void setOrdererTel(String ordererTel) {
        this.ordererTel = ordererTel;
    }
    public SettlementSendInfo(){
        this.setXml( 1 );
        this.setVersion( 2 );
        this.setCharacterCode("UTF-8");
        this.setConveniCode(0);
        this.setDeliveryCode("99");
    }
}
