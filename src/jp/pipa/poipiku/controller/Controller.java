package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.CodeEnum;

public class Controller {
	public ErrorKind errorKind = ErrorKind.Unknown;
	public enum ErrorKind implements CodeEnum<ErrorKind> {
		None(0),
		DoRetry(-10),	    // リトライして欲しい。それでもダメなら問い合わせて欲しい。
		NeedInquiry(-20),	// 決済されているか不明なエラー。運営に問い合わせて欲しい。
		CardAuth(-30),    // カード認証周りのエラー。
		Unknown(-99);     // 不明。通常ありえない。

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private ErrorKind(int code) {
			this.code = code;
		}
	}
}
