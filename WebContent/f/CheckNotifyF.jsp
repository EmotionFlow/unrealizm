<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class CheckNotifyCParam {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			//cRequest.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class CheckNotifyC {
	public int m_nCheckComment = 0;
	public int m_nCheckFollow = 0;
	public int m_nCheckHeart = 0;
	public int m_nNotifyComment = 0;
	public int m_nNotifyFollow = 0;
	public int m_nNotifyHeart = 0;
	public boolean GetResults(CheckNotifyCParam cParam) {
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

			// Check Comment
			strSql = "SELECT COUNT(*) as content_num FROM comments_0000 WHERE ((content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND comments_0000.user_id!=?) OR to_user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cState.setInt(3, cParam.m_nUserId);
			cState.setInt(4, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCheckComment = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Check Follower
			strSql = "SELECT  COUNT(*) as content_num FROM follows_0000 WHERE follows_0000.follow_user_id=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCheckFollow = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Check Heart
			strSql = "SELECT COUNT(*) as content_num FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_check_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nCheckHeart = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Notify Comment
			strSql = "SELECT COUNT(*) as content_num FROM comments_0000 WHERE ((content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND comments_0000.user_id!=?) OR to_user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_notify_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cState.setInt(3, cParam.m_nUserId);
			cState.setInt(4, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nNotifyComment = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Notify Follower
			strSql = "SELECT  COUNT(*) as content_num FROM follows_0000 WHERE follows_0000.follow_user_id=? AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_notify_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nNotifyFollow = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Notify Heart
			strSql = "SELECT COUNT(*) as content_num FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND upload_date>CURRENT_DATE-7 AND upload_date>(SELECT last_notify_date FROM users_0000 WHERE user_id=?)";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if (cResSet.next()) {
				m_nNotifyHeart = cResSet.getInt("content_num");
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time
			strSql = "UPDATE users_0000 SET last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

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
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

CheckNotifyCParam cParam = new CheckNotifyCParam();
cParam.GetParam(request);
cParam.m_nUserId = cCheckLogin.m_nUserId;

CheckNotifyC cResults = new CheckNotifyC();
boolean bRtn = cResults.GetResults(cParam);
%>{
"check_comment":<%=cResults.m_nCheckComment%>,
"check_follow":<%=cResults.m_nCheckFollow%>,
"check_heart":<%=cResults.m_nCheckHeart%>,
"notify_comment":<%=cResults.m_nNotifyComment%>,
"notify_follow":<%=cResults.m_nNotifyFollow%>,
"notify_heart":<%=cResults.m_nNotifyHeart%>
}