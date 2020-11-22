package jp.pipa.poipiku.settlement.epsilon;

import java.lang.reflect.Field;

public class SettlementCancelResultInfo {
    public String userId;
    public String itemCode;
    public String itemPrice;
    public String missionCode;
    public String result;
    public String errCode;
    public String errDetail;

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Class: " + this.getClass().getCanonicalName() + "\n");
        sb.append("Settings:\n");
        for (Field field : this.getClass().getDeclaredFields()) {
            try {
                field.setAccessible(true);
                sb.append(field.getName() + " = " + field.get(this) + "\n");
            } catch (IllegalAccessException e) {
                sb.append(field.getName() + " = " + "access denied\n");
            }
        }
        return sb.toString();
    }
}
