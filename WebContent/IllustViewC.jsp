<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class IllustViewCParam {
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


class IllustViewC {
	public CContent m_cContent = new CContent();

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
			strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name FROM contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id WHERE contents_0000.content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent = new CContent(cResSet);
				m_cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				m_cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				if(m_cContent.m_cUser.m_strFileName.isEmpty()) m_cContent.m_cUser.m_strFileName="/img/default_user.jpg";
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(m_cContent.m_nContentId<=0) return false;

			// follow
			int m_nFollow = CUser.FOLLOW_HIDE;
			if(m_cContent.m_nUserId != cParam.m_nAccessUserId) {
				strSql = "SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=? LIMIT 1";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, m_cContent.m_nUserId);
				cResSet = cState.executeQuery();
				m_nFollow = (cResSet.next())?CUser.FOLLOW_FOLLOWING:CUser.FOLLOW_NONE;
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			}
			m_cContent.m_cUser.m_nFollowing = m_nFollow;

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