<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class ActivityListCParam {
	public int m_nUserId = -1;
	public int m_nMode = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nMode = Common.ToInt(cRequest.getParameter("MOD"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}


class ActivityListC {
	public Vector<CComment> m_vComment = new Vector<CComment>();

	public boolean GetResults(ActivityListCParam cParam) {
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

			// Comment
			if(cParam.m_nMode<=0) {
				strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname, T2.nickname as to_nickname FROM (comments_0000 INNER JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id) LEFT JOIN users_0000 as T2 ON comments_0000.to_user_id=T2.user_id  WHERE ((content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) AND comments_0000.user_id!=?) OR to_user_id=?) ORDER BY comment_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nUserId);
				cState.setInt(3, cParam.m_nUserId);
			} else {
				strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname, T2.nickname as to_nickname FROM (comments_0000 INNER JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id) LEFT JOIN users_0000 as T2 ON comments_0000.to_user_id=T2.user_id  WHERE comments_0000.user_id=? ORDER BY comment_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
			}
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment();
				cComment.m_nCommentId		= cResSet.getInt("comment_id");
				cComment.m_nContentId		= cResSet.getInt("content_id");
				cComment.m_nUserId			= cResSet.getInt("user_id");
				cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cComment.m_strDescription	= Common.ToString(cResSet.getString("description"));
				cComment.m_nToUserId		= cResSet.getInt("to_user_id");
				cComment.m_strToNickName	= Common.ToString(cResSet.getString("to_nickname"));
				cComment.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
				cComment.m_nCommentType		= 0;
				if(cComment.m_strFileName.length()<=0) cComment.m_strFileName="/img/default_user.jpg";
				m_vComment.add(cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Follow
			if(cParam.m_nMode<=0) {
				strSql = "SELECT follows_0000.*, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.user_id=users_0000.user_id WHERE follows_0000.follow_user_id=? ORDER BY follow_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cContent = new CComment();
					cContent.m_nUserId			= cResSet.getInt("user_id");
					cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
					cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
					cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
					cContent.m_nCommentType	= 1;
					if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
					m_vComment.addElement(cContent);
				}
			} else {
				strSql = "SELECT follows_0000.*, nickname, file_name FROM follows_0000 INNER JOIN users_0000 ON follows_0000.follow_user_id=users_0000.user_id WHERE follows_0000.user_id=? ORDER BY follow_id DESC LIMIT 100";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cContent = new CComment();
					cContent.m_nUserId			= cResSet.getInt("follow_user_id");
					cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
					cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
					cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
					cContent.m_nCommentType	= 1;
					if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
					m_vComment.addElement(cContent);
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// Heart
			if(cParam.m_nMode<=0) {
				strSql = "SELECT bookmarks_0000.*, users_0000.file_name, users_0000.nickname FROM bookmarks_0000 LEFT JOIN users_0000 ON bookmarks_0000.user_id=users_0000.user_id WHERE content_id IN (SELECT content_id FROM contents_0000 WHERE user_id=?) ORDER BY bookmark_id DESC LIMIT 200";
			} else {
				strSql = "SELECT T3.user_id, T1.content_id, T1.upload_date, T3.file_name, T3.nickname FROM (bookmarks_0000 as T1 LEFT JOIN contents_0000 as T2 ON T1.content_id=T2.content_id) LEFT JOIN users_0000 as T3 ON T2.user_id=T3.user_id WHERE T1.user_id=? ORDER BY bookmark_id DESC LIMIT 200";
			}
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cContent = new CComment();
				cContent.m_nContentId		= cResSet.getInt("content_id");
				cContent.m_nUserId			= cResSet.getInt("user_id");
				cContent.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
				cContent.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
				cContent.m_timeUploadDate	= cResSet.getTimestamp("upload_date");
				cContent.m_nCommentType		= 2;
				if(cContent.m_strFileName.isEmpty()) cContent.m_strFileName="/img/default_user.jpg";
				m_vComment.add(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			// Sort Time Line
			Collections.sort(m_vComment, new Comparator<CComment>(){
				public int compare(CComment obj1, CComment obj2){
					CComment cComment1 =(CComment)obj1;
					CComment cComment2 =(CComment)obj2;
					return cComment2.m_timeUploadDate.compareTo(cComment1.m_timeUploadDate);
				}
			});


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