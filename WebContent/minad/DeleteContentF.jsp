<%@page import="java.util.Locale.Category"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class DeleteMakingCParam {
	public int m_nContentId = -1;
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(cRequest.getParameter("ID"));
			m_nContentId		= Common.ToInt(cRequest.getParameter("TD"));
		} catch(Exception e) {
			m_nContentId = -1;
			m_nUserId = -1;
		}
	}
}

class DeleteMakingC {
	CContent cContent = new CContent();

	public boolean GetResults(DeleteMakingCParam cParam) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// イラスト存在確認(不正アクセス対策)
			boolean bExist = false;
			strSql = "SELECT * FROM contents_0000 WHERE content_id=? AND user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				bExist = true;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			if(!bExist) {
				return false;
			}

			// delete step comment
			strSql ="DELETE FROM comments_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete tags
			strSql ="DELETE FROM tags_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete bookmark
			strSql ="DELETE FROM bookmarks_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete making
			strSql ="DELETE FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete files
			CImage.DeleteFiles(getServletContext().getRealPath(String.format("/user_img01/%09d/%09d.jpg", cParam.m_nUserId, cParam.m_nContentId)));

			bRtn = true;
		} catch(Exception e) {
			Log.d(strSql);
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
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

DeleteMakingCParam cParam = new DeleteMakingCParam();
cParam.GetParam(request);

System.out.println(cCheckLogin.m_nUserId);

if(cCheckLogin.m_nUserId != 1) {
	return;
}

DeleteMakingC cResults = new DeleteMakingC();
boolean bRtn = cResults.GetResults(cParam);
%><%=bRtn%>