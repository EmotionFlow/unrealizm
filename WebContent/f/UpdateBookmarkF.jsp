<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.regex.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ page import="javax.mail.*"%>
<%@ page import="javax.mail.internet.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class UpdateBookmarkCParam {
	public int m_nContentId = -1;
	public int m_nUserId = -1;
	public boolean m_bBookmark = false;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId	= Common.ToInt(cRequest.getParameter("UID"));
			m_nContentId	= Common.ToInt(cRequest.getParameter("CID"));
			m_bBookmark	= (Common.ToInt(cRequest.getParameter("CHK"))==1);
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
			m_bBookmark = false;
		}
	}
}

class UpdateBookmarkC {
	public int GetResults(UpdateBookmarkCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			try {
				if(cParam.m_bBookmark) {
					strSql ="INSERT INTO bookmarks_0000(user_id, content_id) VALUES(?, ?)";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nUserId);
					cState.setInt(2, cParam.m_nContentId);
					cState.executeUpdate();
					cState.close();cState=null;
				} else {
					strSql ="DELETE FROM bookmarks_0000 WHERE user_id=? AND content_id=?";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nUserId);
					cState.setInt(2, cParam.m_nContentId);
					cState.executeUpdate();
					cState.close();cState=null;
				}
			} catch (Exception e) {
				System.out.println(strSql);
				e.printStackTrace();
			}

			strSql ="UPDATE contents_0000 SET bookmark_num=(SELECT COUNT(content_id) FROM bookmarks_0000 WHERE content_id=?) WHERE content_id=? RETURNING bookmark_num";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setInt(2, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				nRtn = cResSet.getInt("bookmark_num");
			}
			cState.close();cState=null;

		} catch(Exception e) {
			System.out.println(strSql);
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
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

UpdateBookmarkCParam cParam = new UpdateBookmarkCParam();
cParam.GetParam(request);

int nRtn = -1;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	UpdateBookmarkC cResults = new UpdateBookmarkC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>{"bookmark_num":<%=nRtn%>}