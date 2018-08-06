<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class IllustHeartCParam {
	public int m_nContentId = -1;
	public int m_nAccessUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId	= Common.ToInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}
}

class IllustHeartC {
	public CContent m_cContent = new CContent();

	public boolean GetResults(IllustHeartCParam cParam) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			m_cContent.m_nContentId = cParam.m_nContentId;

			// Heart
			strSql = "SELECT bookmarks_0000.*, users_0000.file_name, users_0000.nickname FROM bookmarks_0000 LEFT JOIN users_0000 ON bookmarks_0000.user_id=users_0000.user_id WHERE content_id=? ORDER BY bookmark_id DESC LIMIT 200";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment();
				cComment.m_nCommentId		= cResSet.getInt("bookmark_id");
				cComment.m_nUserId			= cResSet.getInt("user_id");
				cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				if(cComment.m_strFileName.length()<=0) cComment.m_strFileName="/img/default_user.jpg";
				m_cContent.m_vComment.add(cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
%>