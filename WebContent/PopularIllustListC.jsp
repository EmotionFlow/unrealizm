<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class PopularIllustListCParam {
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

class PopularIllustListC {
	public int SELECT_MAX_GALLERY = 30;
	public ArrayList<CContent> m_vContentList = new ArrayList<CContent>();
	int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean GetResults(PopularIllustListCParam cParam) {
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

			// POPULAR
			if(SELECT_MAX_GALLERY>0) {
				strSql = "SELECT count(*) FROM contents_0000 WHERE bookmark_num>10 AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nAccessUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				strSql = "SELECT * FROM contents_0000 WHERE bookmark_num>10 AND user_id NOT IN(SELECT block_user_id FROM blocks_0000 WHERE user_id=?) AND user_id NOT IN(SELECT user_id FROM blocks_0000 WHERE block_user_id=?) ORDER BY content_id DESC OFFSET ? LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nAccessUserId);
				cState.setInt(3, cParam.m_nPage * SELECT_MAX_GALLERY);
				cState.setInt(4, SELECT_MAX_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CContent cContent = new CContent();
					cContent.m_nUserId		= cResSet.getInt("user_id");
					cContent.m_nContentId		= cResSet.getInt("content_id");
					cContent.m_strFileName	= Common.ToString(cResSet.getString("file_name"));

					m_nEndId = cContent.m_nContentId;
					m_vContentList.add(cContent);
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