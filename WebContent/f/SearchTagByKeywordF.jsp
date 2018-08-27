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
class NewArrivalCParam {
	public int m_nStartId = -1;
	public int m_nSelectMax = -1;
	public String m_strKeyword = "";

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nStartId		= Common.ToInt(cRequest.getParameter("SID"));
			m_nSelectMax	= Common.ToIntN(cRequest.getParameter("PNM"), 30, 100);
			m_strKeyword	= Common.ToString(cRequest.getParameter("KWD"));
		} catch(Exception e) {
			m_nStartId = -1;
			m_nSelectMax = -1;
		}
	}
}

class NewArrivalC {
	public ArrayList<String> m_vContentList = new ArrayList<String>();
	int m_nEndId = -1;

	public boolean GetResults(NewArrivalCParam cParam) {
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
			if(cParam.m_nStartId>0) {
				m_nEndId = cParam.m_nStartId;
				strSql = "select tag_txt, count(*) from tags_0000 where tag_txt ilike ? group by tag_txt order by count(*) desc offset ? limit ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cState.setInt(2, cParam.m_nStartId);
				cState.setInt(3, cParam.m_nSelectMax);
				m_nEndId = cParam.m_nStartId + cParam.m_nSelectMax;
			} else {
				strSql = "select tag_txt, count(*) from tags_0000 where tag_txt ilike ? group by tag_txt order by count(*) desc limit ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cState.setInt(2, cParam.m_nSelectMax);
				cParam.m_nStartId = 0;
				m_nEndId = cParam.m_nSelectMax;
			}
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vContentList.add(Common.ToString(cResSet.getString("tag_txt")));
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
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

NewArrivalCParam cParam = new NewArrivalCParam();
cParam.GetParam(request);

NewArrivalC cResults = new NewArrivalC();
boolean bRtn = cResults.GetResults(cParam);
%>{
"start_id":<%=cParam.m_nStartId%>,
"end_id":<%=cResults.m_nEndId%>,
"result_num":<%=cResults.m_vContentList.size()%>,
"result":[
<%
for (int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	String strKeyword = cResults.m_vContentList.get(nCnt);
%>
{
"keyword" : "<%=CEnc.E(strKeyword)%>"
}<%=(nCnt<cResults.m_vContentList.size()-1)?",":""%>
<%
}
%>
]
}