<%@page import="jp.pipa.poipiku.ResourceBundleControl.CResourceBundleUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class ShowEmojiC {
	public int m_nContentId = -1;

	public void getParam(HttpServletRequest request) {
		try {
			m_nContentId	= Util.toInt(request.getParameter("IID"));
			request.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nContentId = -1;
		}
	}

	ArrayList<CComment> m_vComment = new ArrayList<CComment>();
	public boolean getResults(CheckLogin checkLogin, ResourceBundleControl _TEX) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "SELECT * FROM comments_0000 WHERE content_id=? ORDER BY comment_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nContentId);
			cResSet = cState.executeQuery();
			while (cResSet.next()) {
				m_vComment.add(new CComment(cResSet));
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}%>
<%
int nRtn = 0;
String strHtml = _TEX.T("Common.NeedLogin");
CheckLogin checkLogin = new CheckLogin(request, response);
if(checkLogin.m_bLogin) {
	ShowEmojiC cResults = new ShowEmojiC();
	cResults.getParam(request);
	cResults.getResults(checkLogin, _TEX);
	cResults.m_vComment.size();
	StringBuilder strRtn = new StringBuilder();
	for(CComment comment : cResults.m_vComment) {
		strRtn.append(String.format("<span class=\"ResEmoji\">%s</span>", CEmoji.parse(comment.m_strDescription)));
	}
	strHtml = strRtn.toString();
	nRtn = 1;
}
%>{
"result_num" : <%=nRtn%>,
"html" : "<%=CEnc.E(strHtml)%>"
}