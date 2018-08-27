package jp.pipa.poipiku.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Log {
	static String calledFrom() {
		String strRtn = "";
		try {
			StackTraceElement[] steArray = Thread.currentThread().getStackTrace();
			if (steArray.length > 3) {
				StackTraceElement ste = steArray[3];
				StringBuilder sb = new StringBuilder();
				sb.append(ste.getMethodName())	// メソッド名取得
					.append("(")
					.append(ste.getFileName())	// ファイル名取得
					.append(":")
					.append(ste.getLineNumber())	// 行番号取得
					.append(")");
				strRtn =  sb.toString();
			}
		} catch(Exception e) {
			;
		}
		return strRtn;
	}

	public static void d(String... args) {
		System.out.print("Log : ");
		DateFormat cDateFromat = new SimpleDateFormat("YYYY/MM/dd HH:mm:ss, ");
		System.out.print(cDateFromat.format(new Date()));
		System.out.print(calledFrom());
		for (String s : args) {
			System.out.print(", "+s);
		}
		System.out.print("\n");
	}
}
