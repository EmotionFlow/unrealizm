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
class IllustListTimeLineCParam {
	public int m_nUsertId = -1;
	public int m_nStartId = -1;
	public int m_nSelectMax = -1;
	public int m_nAccessUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try
		{
			cRequest.setCharacterEncoding("UTF-8");
			m_nUsertId		= Common.ToInt(cRequest.getParameter("ID"));
			m_nStartId		= Common.ToInt(cRequest.getParameter("SID"));
			m_nSelectMax	= Common.ToIntN(cRequest.getParameter("PNM"), 10, 20);
		}
		catch(Exception e)
		{
			m_nStartId = -1;
			m_nSelectMax = -1;
		}
	}
}

class IllustListTimeLineC {
	public Vector<CContent> m_vContentList = new Vector<CContent>();
	int m_nEndId = -1;

	public boolean GetResults(IllustListTimeLineCParam cParam) {
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
				strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name, bookmarks_0000.content_id as bookmark FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE contents_0000.user_id=? AND contents_0000.content_id<? ORDER BY content_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nUsertId);
				cState.setInt(3, cParam.m_nStartId);
				cState.setInt(4, cParam.m_nSelectMax);
			} else {
				strSql = "SELECT contents_0000.*, nickname, users_0000.file_name as user_file_name, bookmarks_0000.content_id as bookmark FROM (contents_0000 INNER JOIN users_0000 ON contents_0000.user_id=users_0000.user_id) LEFT JOIN bookmarks_0000 ON contents_0000.content_id=bookmarks_0000.content_id AND bookmarks_0000.user_id=? WHERE contents_0000.user_id=? ORDER BY content_id DESC LIMIT ?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nAccessUserId);
				cState.setInt(2, cParam.m_nUsertId);
				cState.setInt(3, cParam.m_nSelectMax);
			}
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				CContent cContent = new CContent(cResSet);
				cContent.m_cUser.m_strNickName	= Common.ToString(cResSet.getString("nickname"));
				cContent.m_cUser.m_strFileName	= Common.ToString(cResSet.getString("user_file_name"));
				cContent.m_bBookmark			= (cResSet.getInt("bookmark")>0);
				if(cContent.m_cUser.m_strFileName.isEmpty()) cContent.m_cUser.m_strFileName="/img/default_user.jpg";

				m_nEndId = cContent.m_nContentId;
				m_vContentList.addElement(cContent);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			// Eeach Comment
			strSql = "SELECT comments_0000.*, T1.file_name, T1.nickname, T2.nickname as to_nickname FROM (comments_0000 INNER JOIN users_0000 as T1 ON comments_0000.user_id=T1.user_id) LEFT JOIN users_0000 as T2 ON comments_0000.to_user_id=T2.user_id  WHERE content_id=? ORDER BY comment_id DESC LIMIT 10";
			cState = cConn.prepareStatement(strSql);
			for(CContent cContent : m_vContentList) {
				cState.setInt(1, cContent.m_nContentId);
				cResSet = cState.executeQuery();
				while (cResSet.next()) {
					CComment cComment = new CComment(cResSet);
					cComment.m_strFileName		= Common.ToString(cResSet.getString("file_name"));
					cComment.m_strNickName		= Common.ToString(cResSet.getString("nickname"));
					cComment.m_strToNickName	= Common.ToString(cResSet.getString("to_nickname"));
					cContent.m_vComment.add(0, cComment);
				}
				cResSet.close();cResSet=null;
			}
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

IllustListTimeLineCParam cParam = new IllustListTimeLineCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

IllustListTimeLineC cResults = new IllustListTimeLineC();
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
"file_name" : "<%=CEnc.E(Common.GetUrl(cContent.m_strFileName))%>",
"description" : "<%=CEnc.E(cContent.m_strDescription)%>",
"nickname" : "<%=CEnc.E(cContent.m_cUser.m_strNickName)%>",
"user_file_name" : "<%=CEnc.E(Common.GetUrl(cContent.m_cUser.m_strFileName))%>",
"bookmark" : <%=(cContent.m_bBookmark)?1:0%>,
"comment_num" : <%=cContent.m_nCommentNum%>,
"bookmark_num" : <%=cContent.m_nBookmarkNum%>,
"category_id" : <%=cContent.m_nCategoryId%>,
"category" : "<%=CEnc.E(_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId)))%>",
"comment":[
<%
for (int nCmtCnt=0; nCmtCnt<cContent.m_vComment.size(); nCmtCnt++) {
	CComment cComment = cContent.m_vComment.get(nCmtCnt);
%>
{
"comment_id" : <%=cComment.m_nCommentId%>,
"user_id" : <%=cComment.m_nUserId%>,
"nickname" : "<%=CEnc.E(cComment.m_strNickName)%>",
"to_user_id" : <%=cComment.m_nToUserId%>,
"to_nickname" : "<%=CEnc.E(cComment.m_strToNickName)%>",
"description" : "<%=CEnc.E(cComment.m_strDescription)%>"
}<%=(nCmtCnt<cContent.m_vComment.size()-1)?",":""%>
<%}%>
]
}<%=(nCnt<cResults.m_vContentList.size()-1)?",":""%>
<%}%>
]
}