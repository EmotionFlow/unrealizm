<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class MyHomeCParam {
	public int m_nAccessUserId = -1;
	public int m_nPage = 0;
	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e)
		{
			;
		}
	}
}

class MyHomeC {
	public int SELECT_MAX_GALLERY = 30;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean GetResults(MyHomeCParam cParam) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		DatabaseMetaData meta = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			meta = cConn.getMetaData();

			// NEW ARRIVAL
			if(SELECT_MAX_GALLERY>0) {
				strSql = "SELECT count(*) FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE (contents_0000.user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?) OR contents_0000.user_id=?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nAccessUserId);
				cState.setInt(3, cParam.m_nAccessUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name, bookmarks_0000.content_id as bookmark FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE (contents_0000.user_id IN (SELECT follow_user_id FROM follows_0000 WHERE user_id=?) OR contents_0000.user_id=?) ORDER BY content_id DESC OFFSET ? LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nAccessUserId);
				cState.setInt(3, cParam.m_nAccessUserId);
				cState.setInt(4, cParam.m_nPage * SELECT_MAX_GALLERY);
				cState.setInt(5, SELECT_MAX_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent();
					cContent.m_nUserId				= cResSet.getInt("user_id");
					cContent.m_nContentId			= cResSet.getInt("content_id");
					cContent.m_timeUploadDate		= cResSet.getTimestamp("upload_date");
					cContent.m_strDescription		= Common.ToString(cResSet.getString("description"));
					cContent.m_strFileName			= Common.ToString(cResSet.getString("file_name"));
					cContent.m_cUser.m_nUserId		= cResSet.getInt("user_id");
					cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
					cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
					cContent.m_bBookmark				= (cResSet.getInt("bookmark")>0);
					cContent.m_nCommentNum			= cResSet.getInt("comment_num");
					cContent.m_nBookmarkNum			= cResSet.getInt("bookmark_num");
					if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
					if(!cContent.m_strDescription.isEmpty()) cContent.m_nCommentNum++;

					m_nEndId = cContent.m_nContentId;
					m_vContentList.add(cContent);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// Eeach Comment
				strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname, T2.nickname as to_nickname FROM (comments_0000 INNER JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id) LEFT JOIN users_0000 as T2 ON comments_0000.to_user_id=T2.user_id  WHERE content_id=? ORDER BY comment_id DESC LIMIT 10";
				cState = cConn.prepareStatement(strSql);
				for(CContent cContent : m_vContentList) {
					cState.setInt(1, cContent.m_nContentId);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						CComment cComment = new CComment();
						cComment.m_nCommentId		= cResSet.getInt("comment_id");
						cComment.m_nUserId			= cResSet.getInt("user_id");
						cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
						cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
						cComment.m_strDescription	= Common.ToString(cResSet.getString("description"));
						cComment.m_nToUserId			= cResSet.getInt("to_user_id");
						cComment.m_strToNickName		= Common.ToString(cResSet.getString("to_nickname"));
						cContent.m_vComment.add(0, cComment);
					}
					cResSet.close();cResSet=null;
				}
				cState.close();cState=null;
			}

			bResult = true;
		} catch(Exception e) {
			System.out.println(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bResult;
	}
}
%>