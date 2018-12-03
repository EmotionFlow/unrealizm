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
			m_nUserId			= Common.ToInt(cRequest.getParameter("UID"));
			m_nContentId		= Common.ToInt(cRequest.getParameter("CID"));
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
			if(cParam.m_nUserId==1) {
				strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cResSet = cState.executeQuery();
				if(cResSet.next()) {
					cParam.m_nUserId = cResSet.getInt("user_id");
					bExist = true;
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
			} else {
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
			}
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

			// delete append files
			strSql ="SELECT * FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			while(cResSet.next()) {
				CContentAppend cContentAppend = new CContentAppend(cResSet);
				try{
					ImageUtil.deleteFiles(getServletContext().getRealPath(cContentAppend.m_strFileName));
				} catch (Exception e) {
					Log.d("connot delete content_append file : " + cContentAppend.m_strFileName);
				}
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
			// delete append data
			strSql ="DELETE FROM contents_appends_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;

			// delete content data
			strSql ="DELETE FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cState.executeUpdate();
			cState.close();cState=null;
			// delete files
			ImageUtil.deleteFiles(getServletContext().getRealPath(String.format("%s/%09d.jpg", Common.getUploadUserPath(cParam.m_nUserId), cParam.m_nContentId)));

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
CheckLogin cCheckLogin = new CheckLogin(request, response);

DeleteMakingCParam cParam = new DeleteMakingCParam();
cParam.GetParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	DeleteMakingC cResults = new DeleteMakingC();
	bRtn = cResults.GetResults(cParam);
}
%><%=bRtn%>