<%@page import="java.util.Locale.Category"%>
<%@ page
language="java"
contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"
import="java.util.*"
import="java.sql.*"
import="javax.sql.*"
import="javax.naming.*"
%>
<%@ include file="/inner/Common.jsp"
%><%!
class IllustListCParam {
	public int m_nUsertId = -1;
	public int m_nStartId = -1;
	public int m_nSelectMax = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
			m_nUsertId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nStartId		= Common.ToInt(cRequest.getParameter("SID"));
			m_nSelectMax	= Common.ToIntN(cRequest.getParameter("PNM"), 30, 100);
		}
		catch(Exception e)
		{
			m_nStartId = -1;
			m_nSelectMax = -1;
		}
	}
}

class IllustListC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();
	int m_nEndId = -1;

	public boolean GetResults(IllustListCParam cParam) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// NEW ARRIVAL
			if(cParam.m_nStartId>0) {
				m_nEndId = cParam.m_nStartId;
				strSql = "SELECT * FROM contents_0000 WHERE user_id=? AND content_id<? ORDER BY content_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUsertId);
				cState.setInt(2, cParam.m_nStartId);
				cState.setInt(3, cParam.m_nSelectMax);
			} else {
				strSql = "SELECT * FROM contents_0000 WHERE user_id=? ORDER BY content_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUsertId);
				cState.setInt(2, cParam.m_nSelectMax);
			}
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
%><%
IllustListCParam cParam = new IllustListCParam();
cParam.GetParam(request);

IllustListC cResults = new IllustListC();
boolean bRtn = cResults.GetResults(cParam);
%>{
"start_id":<%=cParam.m_nStartId%>,
"end_id":<%=cResults.m_nEndId%>,
"result_num":<%=cResults.m_vContentList.size()%>,
"result":[
<%
for (int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
%>
{
"content_id" : <%=cContent.m_nContentId%>,
"user_id" : <%=cContent.m_nUserId%>,
"file_name" : "<%=CEnc.E(Common.GetUrl(cContent.m_strFileName))%>"
}<%=(nCnt<cResults.m_vContentList.size()-1)?",":""%>
<%
}
%>
]
}