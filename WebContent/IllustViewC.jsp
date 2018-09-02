<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class IllustViewCParam {
	//public int m_nUserId = -1;
	public int m_nContentId = -1;
	public int m_nAccessUserId = -1;
	public String m_strAccessIp = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {

			cRequest.setCharacterEncoding("UTF-8");
			//m_nUserId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId		= Common.ToInt(cRequest.getParameter("TD"));
			m_strAccessIp	= cRequest.getRemoteAddr();

			/*
			String strSessionId = "";
			HttpSession session=cRequest.getSession(false);
			if(session==null) session = cRequest.getSession(true);
			if(session!=null) strSessionId = session.getId();
			if(strSessionId.length()>0) m_strAccessIp = strSessionId;
			*/
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}
}


class IllustViewC {
	public CUser m_cUser = new CUser();
	public CContent m_cContent = new CContent();
	public boolean m_bOwner = false;
	public boolean m_bBookmark = false;
	public boolean m_bFollow = false;
	public boolean m_bReply = false;

	public boolean GetResults(IllustViewCParam cParam) {
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

			// content main
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name, bookmarks_0000.content_id as bookmark FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE contents_0000.content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nAccessUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				m_cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				m_cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				m_cContent.m_bBookmark			= (cResSet.getInt("bookmark")>0);
				if(m_cContent.m_cUser.m_strFileName.isEmpty()) m_cContent.m_cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(cParam.m_nAccessUserId == m_cContent.m_nUserId) {
				m_bOwner = true;
			}

			// author profile
			strSql = "SELECT * FROM users_0000 WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_cContent.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cUser.m_nUserId		= cResSet.getInt("user_id");
				m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				m_cUser.m_strProfile	= Common.ToString(cResSet.getString("profile"));
				m_cUser.m_strFileName	= Common.ToString(cResSet.getString("file_name"));
				if(m_cUser.m_strProfile.equals(""))  m_cUser.m_strProfile = "(no profile)";
				if(m_cUser.m_strFileName.equals("")) m_cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// delete check
			if(m_cContent.m_nContentId<1) {
				try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
				return false;
			}

			// Eeach Emoji
			strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT 240";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_cContent.m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CComment cComment = new CComment(cResSet);
				m_cContent.m_vComment.add(0, cComment);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// bookmark
			strSql = "SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nAccessUserId);
			cState.setInt(2, m_cContent.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_bBookmark = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			// follow
			strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nAccessUserId);
			cState.setInt(2, m_cContent.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_bFollow = true;
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