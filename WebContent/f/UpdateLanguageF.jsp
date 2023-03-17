<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

int langId = 1;

Connection connection = null;
PreparedStatement statement = null;
ResultSet resultSet = null;
String strSql = "";

if (!g_isApp) {
	final String strLocale = Util.toString(request.getParameter("LANGID"));
	if (!strLocale.isEmpty()) {
		langId = SupportedLocales.findId(strLocale);
	} else {
		return;
	}

	try {
		connection = DatabaseUtil.dataSource.getConnection();
		strSql = "UPDATE users_0000 SET lang_id=? WHERE user_id=?";
		statement = connection.prepareStatement(strSql);
		statement.setInt(1, langId);
		statement.setInt(2, checkLogin.m_nUserId);
		statement.executeUpdate();
		statement.close();statement =null;
		CacheUsers0000.getInstance().clearUser(checkLogin.m_strHashPass);
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try{if(statement != null) statement.close();statement =null;} catch(Exception ignored) {;}
		try{if(connection != null) connection.close();connection =null;} catch(Exception ignored) {;}
	}
} else {
	/**
	 * アプリ版は起動時にUpdateLanguageFにアクセスしており、端末の言語情報を送信している（と思う）。
	 * ブラウザ版で複数言語対応を実装した関係で、このアクセスがあることで、DB上の言語設定（users_0000.lang_id）
	 * が意図せず更新されてしまい、ユーザーが混乱してしまっていた。
	 * そこで、cgi-parameter "LD" でアクセスされた場合はアプリからのアクセスと判定し、DB上の言語設定更新をしない
	 * ようにした。一応、DB上のlang_idを返すようにしたが、iOS版のコードを読む限り、本APIの戻り値は使用されていない。
	 */
	try {
		connection = DatabaseUtil.dataSource.getConnection();
		strSql = "SELECT lang_id FROM users_0000 WHERE user_id=?";
		statement = connection.prepareStatement(strSql);
		statement.setInt(1, checkLogin.m_nUserId);
		resultSet = statement.executeQuery();
		if (resultSet.next()) {
			langId = resultSet.getInt(1);
		} else {
			return;
		}
	} catch(Exception e) {
		e.printStackTrace();
	} finally {
		try{if(resultSet != null) resultSet.close();resultSet =null;} catch(Exception ignored) {;}
		try{if(statement != null) statement.close();statement =null;} catch(Exception ignored) {;}
		try{if(connection != null) connection.close();connection =null;} catch(Exception ignored) {;}
	}

}

%>{"result":<%=langId%>}
