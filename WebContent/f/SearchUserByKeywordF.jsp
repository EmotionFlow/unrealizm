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
<%@ include file="/inner/CheckLogin.jsp"
%><%!
class FollowListCParam {
	public int m_nStartId = -1;
	public int m_nSelectMax = -1;
	public String m_strKeyword = "";

	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
			m_nStartId		= Common.ToInt(cRequest.getParameter("SID"));
			m_nSelectMax	= Common.ToIntN(cRequest.getParameter("PNM"), 30, 100);
			m_strKeyword	= Common.ToString(cRequest.getParameter("KWD"));
		}
		catch(Exception e)
		{
			m_nStartId = -1;
			m_nSelectMax = -1;
		}
	}
}

class FollowListC {
	public Vector<CUser> m_vContentList = new Vector<CUser>();
	int m_nEndId = -1;

	public boolean GetResults(FollowListCParam cParam) {
		boolean bResult = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		DatabaseMetaData meta = null;
		String strSql = "";

		if(cParam.m_strKeyword.equals("")) {
			return true;
		}

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();
			meta = cConn.getMetaData();

			// NEW ARRIVAL
			if(cParam.m_nStartId>0) {
				m_nEndId = cParam.m_nStartId;
				strSql = "SELECT * FROM users_0000 WHERE user_id<? AND nickname ILIKE ? ORDER BY user_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nStartId);
				cState.setString(2, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cState.setInt(3, cParam.m_nSelectMax);
			} else {
				strSql = "SELECT * FROM users_0000 WHERE nickname ILIKE ? ORDER BY user_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, Common.EscapeSqlLike(cParam.m_strKeyword, meta.getSearchStringEscape()));
				cState.setInt(2, cParam.m_nSelectMax);
			}
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CUser cContent = new CUser();
				cContent.m_nUserId		= cResSet.getInt("user_id");
				cContent.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_strFileName	= Common.ToString(cResSet.getString("file_name"));
				if(cContent.m_strFileName.length()<=0) cContent.m_strFileName="/img/default_user.jpg";

				m_nEndId = cContent.m_nUserId;
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
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

FollowListCParam cParam = new FollowListCParam();
cParam.GetParam(request);

FollowListC cResults = new FollowListC();
boolean bRtn = cResults.GetResults(cParam);
%>{
"start_id":<%=cParam.m_nStartId%>,
"end_id":<%=cResults.m_nEndId%>,
"result_num":<%=cResults.m_vContentList.size()%>,
"result":[
<%
for (int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CUser cContent = cResults.m_vContentList.get(nCnt);
%>
{
"user_id" : <%=cContent.m_nUserId%>,
"file_name" : "<%=CEnc.E(Common.GetUrl(cContent.m_strFileName))%>",
"nickname" : "<%=CEnc.E(cContent.m_strNickName)%>"
}<%=(nCnt<cResults.m_vContentList.size()-1)?",":""%>
<%}%>
]
}