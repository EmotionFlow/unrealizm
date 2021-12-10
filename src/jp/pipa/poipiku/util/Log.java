package jp.pipa.poipiku.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class Log {
	private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss, ");
	static String calledFrom() {
		try {
			final StackTraceElement[] steArray = Thread.currentThread().getStackTrace();
			if (steArray.length > 3) {
				StackTraceElement ste = steArray[3];
				return ste.getMethodName() +    // メソッド名取得
						"(" +
						ste.getFileName() +    // ファイル名取得
						":" +
						ste.getLineNumber() +    // 行番号取得
						")";
			}
		} catch(Exception ignored) {
		}
		return "";
	}

	public static void d(String... args) {
		System.out.print("Log : ");
		System.out.print(LocalDateTime.now().format(formatter));
		System.out.print(calledFrom());
		for (String s : args) {
			System.out.print(", "+s);
		}
		System.out.print("\n");
	}

	public static void d(String arg1, int arg2) {
		System.out.print("Log : ");
		System.out.print(LocalDateTime.now().format(formatter));
		System.out.print(calledFrom());
		System.out.printf("%s:%d", arg1, arg2);
		System.out.print("\n");
	}
}
