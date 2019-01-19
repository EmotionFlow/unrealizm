<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateBookmarkCParam {
	public int m_nUserId = -1;
	public int m_nContentId = -1;


	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId = Common.ToInt(cRequest.getParameter("UID"));
			m_nContentId = Common.ToInt(cRequest.getParameter("IID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class UpdateBookmarkC {
	public int GetResults(UpdateBookmarkCParam cParam) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			boolean bBookmarking = false;
			// now following check
			strSql ="SELECT * FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			bBookmarking = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(!bBookmarking) {
				strSql ="INSERT INTO bookmarks_0000(user_id, content_id) VALUES(?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = CContent.BOOKMARK_BOOKMARKING;
				strSql ="UPDATE contents_0000 SET bookmark_num=bookmark_num+1 WHERE content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;

			} else {
				strSql ="DELETE FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = CContent.BOOKMARK_NONE;
				strSql ="UPDATE contents_0000 SET bookmark_num=bookmark_num-1 WHERE content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateBookmarkCParam cParam = new UpdateBookmarkCParam();
cParam.GetParam(request);

int nRtn = -1;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	UpdateBookmarkC cResults = new UpdateBookmarkC();
	nRtn = cResults.GetResults(cParam);
}
%>{"result":<%=nRtn%>}