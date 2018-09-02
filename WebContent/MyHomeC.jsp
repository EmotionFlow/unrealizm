<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
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
					CContent cContent = new CContent(cResSet);
					cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
					cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
					cContent.m_bBookmark			= (cResSet.getInt("bookmark")>0);
					if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";
					m_nEndId = cContent.m_nContentId;
					m_vContentList.add(cContent);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				// Eeach Emoji
				strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id DESC LIMIT 240";
				cState = cConn.prepareStatement(strSql);
				for(CContent cContent : m_vContentList) {
					cState.setInt(1, cContent.m_nContentId);
					cResSet = cState.executeQuery();
					while (cResSet.next()) {
						CComment cComment = new CComment(cResSet);
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