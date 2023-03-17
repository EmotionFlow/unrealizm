<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateFollowGenreC {
	public static final int OK_INSERT = 1;
	public static final int OK_DELETE = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_MAX = -2;
	public static final int ERR_UNKNOWN = -99;

	public int userId = -1;
	public int genreId = -1;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			userId	= Util.toInt(request.getParameter("UID"));
			genreId	= Util.toInt(request.getParameter("GD"));
		} catch(Exception e) {
			userId = -1;
		}
	}

	public int m_nContentsNum = 0;
	public int getResults(CheckLogin checkLogin) {
		if(genreId<1) return ERR_UNKNOWN;

		int nRtn = ERR_UNKNOWN;
		DataSource dataSource = null;
		Connection connection = null;
		PreparedStatement statement = null;
		ResultSet resultSet = null;
		String strSql = "";

		try {
			dataSource = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			connection = dataSource.getConnection();

			boolean bFollowing = false;
			// now following check
			strSql ="SELECT * FROM follow_genres WHERE user_id=? AND genre_id=?";
			statement = connection.prepareStatement(strSql);
			statement.setInt(1, userId);
			statement.setInt(2, genreId);
			resultSet = statement.executeQuery();
			bFollowing = resultSet.next();
			resultSet.close();resultSet=null;
			statement.close();statement=null;


			if(!bFollowing) {
				strSql = "SELECT count(*) FROM follow_genres WHERE user_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, checkLogin.m_nUserId);
				resultSet = statement.executeQuery();
				if (resultSet.next()) {
					m_nContentsNum = resultSet.getInt(1);
				}
				resultSet.close();resultSet=null;
				statement.close();statement=null;
				if(m_nContentsNum>=Common.GENRE_NUM[checkLogin.m_nPassportId]) return ERR_MAX;

				strSql ="INSERT INTO follow_genres(user_id, genre_id) VALUES(?, ?)";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, userId);
				statement.setInt(2, genreId);
				statement.executeUpdate();
				statement.close();statement=null;
				nRtn = OK_INSERT;
			} else {
				strSql ="DELETE FROM follow_genres WHERE user_id=? AND genre_id=?";
				statement = connection.prepareStatement(strSql);
				statement.setInt(1, userId);
				statement.setInt(2, genreId);
				statement.executeUpdate();
				statement.close();statement=null;
				nRtn = OK_DELETE;
			}
		} catch(Exception e) {
			e.printStackTrace();
			nRtn = ERR_UNKNOWN;
		} finally {
			try{if(resultSet!=null){resultSet.close();resultSet=null;}}catch(Exception e){;}
			try{if(statement!=null){statement.close();statement=null;}}catch(Exception e){;}
			try{if(connection!=null){connection.close();connection=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateFollowGenreC results = new UpdateFollowGenreC();
results.getParam(request);

int nRtn = UpdateFollowGenreC.ERR_NOT_LOGIN;
if(checkLogin.m_bLogin && results.userId==checkLogin.m_nUserId) {
	nRtn = results.getResults(checkLogin);
}
String strMessage = "";
if(nRtn<0) {
	switch(nRtn) {
	case UpdateFollowGenreC.OK_INSERT:
	case UpdateFollowGenreC.OK_DELETE:
		strMessage = _TEX.T("Common.Saved");
		break;
	case UpdateFollowGenreC.ERR_NOT_LOGIN:
		strMessage = _TEX.T("UpdateFollowTagC.ERR_NOT_LOGIN");
		break;
	case UpdateFollowGenreC.ERR_MAX:
		strMessage = String.format(_TEX.T("UpdateFollowGenre.ERR_MAX"), Common.GENRE_NUM[checkLogin.m_nPassportId]);
		break;
	case UpdateFollowGenreC.ERR_UNKNOWN:
	default:
		strMessage = _TEX.T("UpdateFollowTagC.ERR_UNKNOWN");
		break;
	}
}

//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
	root.put("result", nRtn);
	root.put("message", strMessage);

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch (JsonGenerationException e) {
	e.printStackTrace();
} finally {
	root = null;
	mapper = null;
}
%>