package jp.pipa.poipiku;

public class Model {
	public ErrorKind errorKind = ErrorKind.Undefined;
	public enum ErrorKind implements CodeEnum<ErrorKind> {
		None(0),
		DbError(-10),	    // sql exceptionなどのDB関連エラー
		StatementError(-20),// 不正な状態遷移エラー
		OtherError(-30),    // その他エラー
		Undefined(-99);       // 不明。通常ありえない。

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
