<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class TopCParam {
	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
		}
		catch(Exception e)
		{
			;
		}
	}
}

class TopC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();
	int m_nEndId = -1;
	public int SELECT_MAX_GALLERY = 0;

	public boolean GetResults(TopCParam cParam) {
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
				strSql = "SELECT * FROM contents_0000 WHERE bookmark_num>10 ORDER BY RANDOM() LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, SELECT_MAX_GALLERY);
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