package jp.pipa.poipiku;

import java.util.*;

public class ResourceSupported {
	static Map<String, Locale> localeMap;
	static public Locale EN = new Locale("en", "");
	static public Locale JA = new Locale("ja", "");
	static public Locale KO = new Locale("ko", "");

	static {
		localeMap = new LinkedHashMap<>();
		localeMap.put("en", EN);
		localeMap.put("ja", JA);
		localeMap.put("ko", KO);
	}
}
