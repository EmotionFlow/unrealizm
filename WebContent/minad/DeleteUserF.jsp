<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

int m_nRtn = 0;

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("UID"));

if(checkLogin.m_nUserId!=1) {
	return;
}

Log.d(String.format("minad DeleteUserV Start:%d", checkLogin.m_nUserId));

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;
String strSql = "";

try {
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	// もらった絵文字だけ消す
	// delete comment
	strSql ="DELETE FROM comments_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
	strSql ="DELETE FROM comments_desc_cache WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete tags
	strSql = "DELETE FROM tags_0000 WHERE tags_0000.content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete bookmark
	strSql = "DELETE FROM bookmarks_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
	strSql = "DELETE FROM bookmarks_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete follow
	strSql = "DELETE FROM follows_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
	strSql = "DELETE FROM follows_0000 WHERE follow_user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete blocks
	strSql = "DELETE FROM blocks_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
	strSql = "DELETE FROM blocks_0000 WHERE block_user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete append data
	strSql ="DELETE FROM contents_appends_0000 WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?)";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete content data
	strSql = "DELETE FROM contents_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete temp email
	strSql = "DELETE FROM temp_emails_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete oauth
	strSql = "DELETE FROM tbloauth WHERE flduserid=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete token
	strSql = "DELETE FROM notification_tokens_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;

	// delete user
	strSql = "DELETE FROM users_0000 WHERE user_id=?";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, m_nUserId);
	cState.executeUpdate();
	cState.close();cState=null;
	// delete files
	File fileDel = new File(getServletContext().getRealPath(Common.getUploadContentsPath(m_nUserId)));
	Common.rmDir(fileDel);

	// キャッシュからもユーザを消す
	CacheUsers0000 users0000 = CacheUsers0000.getInstance();
	users0000.clearUser(m_nUserId);

	m_nRtn = 1;

} catch(Exception e) {
	Log.d(strSql);
	e.printStackTrace();
} finally {
	try{if(cState != null) cState.close();cState=null;} catch(Exception e) {;}
	try{if(cConn != null) cConn.close();cConn=null;} catch(Exception e) {;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}

if(m_nRtn>0) {
	Log.d(String.format("DeleteUserV Complete:%d", m_nUserId));
}
%>{"result":<%=m_nRtn%>}
