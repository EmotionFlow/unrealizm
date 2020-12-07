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
		sb.append("Class: ").append(this.getClass().getCanonicalName()).append("\n");
		sb.append("Settings:\n");
		for (Field field : this.getClass().getDeclaredFields()) {
			try {
				field.setAccessible(true);
				sb.append(field.getName()).append(" = ").append(field.get(this)).append("\n");
			} catch (IllegalAccessException e) {
				sb.append(field.getName()).append(" = ").append("access denied\n");
			}
		}
		return sb.toString();
	}
}
