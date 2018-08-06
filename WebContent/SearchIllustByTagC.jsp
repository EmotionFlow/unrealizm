<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class SearchIllustByTagCParam {
	public String m_strKeyword = "";
	public int m_nPage = 0;

	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
			m_strKeyword	= Common.TrimAll(Common.ToString(cRequest.getParameter("KWD")));
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
		}
		catch(Exception e)
		{
			m_strKeyword = "";
			m_nPage = 0;
		}
	}
}

class SearchIllustByTagC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();
	int m_nEndId = -1;
	public int SELECT_MAX_GALLERY = 30;
	public int m_nContentsNum = 0;

	public boolean GetResults(SearchIllustByTagCParam cParam) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		DatabaseMetaData meta = null;
		String strSql = "";

		if(cParam.m_strKeyword.isEmpty()) return false;

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			meta = cConn.getMetaData();

			// NEW ARRIVAL
			if(SELECT_MAX_GALLERY>0) {
				strSql = "SELECT COUNT(*) FROM contents_0000 WHERE content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=?)";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, cParam.m_strKeyword);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				strSql = "SELECT * FROM contents_0000 WHERE content_id IN (SELECT content_id FROM tags_0000 WHERE tag_txt=?) ORDER BY content_id DESC OFFSET ? LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, cParam.m_strKeyword);
				cState.setInt(2, SELECT_MAX_GALLERY*cParam.m_nPage);
				cState.setInt(3, SELECT_MAX_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent();
					cContent.m_nUserId		= cResSet.getInt("user_id");
					cContent.m_nContentId		= cResSet.getInt("content_id");
					cContent.m_strFileName	= Common.ToString(cResSet.getString("file_name"));

					m_nEndId = cContent.m_nContentId;
					m_vContentList.addElement(cContent);
				}
				cResSet.close();cResSet=null;
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