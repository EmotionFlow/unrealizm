package jp.pipa.poipiku.util;

public class CEnc {
	public static String E(String value) {

		if (value == null) return "";

		char[] charValue = value.toCharArray();
		StringBuilder result = new StringBuilder();
		for (char ch : charValue){
			if (ch != '_' && !(ch >= '0' && '9' >= ch) && !(ch >= 'a' && 'z' >= ch) && !(ch >= 'A' && 'Z' >= ch)) {
				result.append(String.format("\\u%04x", (int)ch));
			} else {
				result.append(ch);
			}
		}
		return result.toString();
	}
}
