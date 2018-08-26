<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="javax.naming.*"%>
<%@page import="javax.sql.*"%>
<%@ include file="/inner/CheckLogin.jsp"%>
<%!
class IllustDetailCParam {
	public int m_nContentId = -1;
	public int m_nAccessUserId = -1;
	public String m_strAccessIp = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nContentId		= Common.ToInt(cRequest.getParameter("TD"));
			m_strAccessIp	= cRequest.getRemoteAddr();
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}
}

class IllustDetailC {
	public CContent m_cContent = new CContent();

	public boolean GetResults(IllustDetailCParam cParam) {
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
			strSql = "SELECT * FROM contents_0000 WHERE content_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nContentId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				m_cContent.m_strFileName = cResSet.getString("file_name");
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