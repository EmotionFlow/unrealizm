<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="javax.sql.*"%>
<%@ page import="javax.naming.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class SearchUserByKeywordCParam {
	public int m_nAccessUserId = -1;
	public int m_nPage = 0;
	public String m_strKeyword = "";
	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nPage = Math.max(Common.ToInt(cRequest.getParameter("PG")), 0);
			m_strKeyword = Common.ToString(cRequest.getParameter("KWD"));
		}
		catch(Exception e) {
			;
		}
	}
}

class SearchUserByKeywordC {
	public int SELECT_MAX_GALLERY = 30;
	public ArrayList<CUser> m_vContentList = new ArrayList<CUser>();
	int m_nEndId = -1;
	public int m_nContentsNum = 0;

	public boolean GetResults(SearchUserByKeywordCParam cParam) {
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
				strSql = "SELECT count(*) FROM users_0000 WHERE nickname ILIKE ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;

				strSql = "SELECT * FROM users_0000 WHERE nickname ILIKE ? ORDER BY user_id DESC OFFSET ? LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cState.setInt(2, cParam.m_nPage * SELECT_MAX_GALLERY);
				cState.setInt(3, SELECT_MAX_GALLERY);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CUser cContent = new CUser();
					cContent.m_nUserId		= cResSet.getInt("user_id");
					cContent.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
					cContent.m_strFileName	= Common.ToString(cResSet.getString("file_name"));
					if(cContent.m_strFileName.length()<=0) cContent.m_strFileName="/img/default_user.jpg";

					m_nEndId = cContent.m_nUserId;
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