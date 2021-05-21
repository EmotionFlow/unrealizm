package jp.pipa.poipiku;

import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;


public final class PassportPayment extends Model{
	public ErrorKind errorKind = ErrorKind.Undefined;

	public boolean exists = false;
	public int userId = -1;
	public int year = -1;
	public int month = -1;
	public enum By implements CodeEnum<By> {
		Undefined(0),
		CreditCard(1),
		Ticket(2);

		static public By byCode(int _code) {
			return CodeEnum.getEnum(By.class, _code);
		}

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private By(int code) {
			this.code = code;
		}
	}
	public By by = By.Undefined;

	public PassportPayment(CheckLogin checkLogin) {
		if(checkLogin == null || !checkLogin.m_bLogin) return;

		userId = checkLogin.m_nUserId;

		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String sql = "";

		try {
			connection = DatabaseUtil.dataSource.getConnection();

			LocalDate now = LocalDate.now();
			sql = "SELECT * FROM passport_payments WHERE user_id=? AND year=? AND month=?";
			statement = connection.prepareStatement(sql);
			statement.setInt(1, userId);
			statement.setInt(2, now.getYear());
			statement.setInt(3, now.getMonthValue());
			resultSet = statement.executeQuery();

			if (resultSet.next()) {
				year = resultSet.getInt("year");
				month = resultSet.getInt("month");
				by = By.byCode(resultSet.getInt("by"));
				exists = true;
			}
		} catch(Exception e) {
			Log.d(sql);
			e.printStackTrace();
			errorKind = ErrorKind.DbError;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception ignored){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception ignored){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception ignored){;}
		}

		errorKind = ErrorKind.None;
	}
}