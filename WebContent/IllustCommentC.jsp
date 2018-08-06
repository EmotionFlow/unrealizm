<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class IllustCommentCParam {
	public int m_nContentId = -1;
	public int m_nAccessUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId		= Common.ToInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}
}

class IllustCommentC {
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bReply = false;

	public boolean GetResults(IllustCommentCParam cParam) {
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


			// First Comment from Content Main
			strSql = "SELECT users_0000.*, contents_0000.description, contents_0000.upload_date FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				CComment cComment = new CComment();
				cComment.m_nUserId			= cResSet.getInt("user_id");
				cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cComment.m_strDescription	= Common.ToString(cResSet.getString("description"));
				cComment.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
				if(cComment.m_strFileName.isEmpty()) cComment.m_strFileName="/img/default_user.jpg";
				if(cComment.m_nUserId==cParam.m_nAccessUserId) m_bOwner=true;
				if(!cComment.m_strDescription.isEmpty()) m_cContent.m_vComment.add(cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			// Comment
			strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname, T2.nickname as to_nickname FROM (comments_0000 INNER JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id) LEFT JOIN users_0000 as T2 ON comments_0000.to_user_id=T2.user_id  WHERE content_id=? ORDER BY comment_id ASC";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment();
				cComment.m_nCommentId		= cResSet.getInt("comment_id");
				cComment.m_nUserId			= cResSet.getInt("user_id");
				cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cComment.m_strDescription	= Common.ToString(cResSet.getString("description"));
				cComment.m_nToUserId		= cResSet.getInt("to_user_id");
				cComment.m_strToNickName	= Common.ToString(cResSet.getString("to_nickname"));
				cComment.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
				if(cComment.m_strFileName.isEmpty()) cComment.m_strFileName="/img/default_user.jpg";
				m_bReply = (m_bOwner && cComment.m_nUserId!=cParam.m_nAccessUserId);
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