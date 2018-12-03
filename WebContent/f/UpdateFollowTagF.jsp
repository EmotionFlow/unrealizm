<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateFollowTagCParam {
	public int m_nUserId = -1;
	public String m_strTagTxt = "";
	public int m_nTypeId = 0;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId	= Common.ToInt(cRequest.getParameter("UID"));
			m_strTagTxt	= Common.TrimAll(cRequest.getParameter("TXT"));
			m_nTypeId	= Common.ToIntN(cRequest.getParameter("TYP"), Common.FOVO_KEYWORD_TYPE_TAG, Common.FOVO_KEYWORD_TYPE_SEARCH);
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class UpdateFollowTagC {
	public int GetResults(UpdateFollowTagCParam cParam) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		if(cParam.m_strTagTxt.isEmpty()) return nRtn;
		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			boolean bFollowing = false;
			// now following check
			strSql ="SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setString(2, cParam.m_strTagTxt);
			cState.setInt(3, cParam.m_nTypeId);
			cResSet = cState.executeQuery();
			bFollowing = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(!bFollowing) {
				strSql ="INSERT INTO follow_tags_0000(user_id, tag_txt, type_id) VALUES(?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setString(2, cParam.m_strTagTxt);
				cState.setInt(3, cParam.m_nTypeId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = 1;
			} else {
				strSql ="DELETE FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setString(2, cParam.m_strTagTxt);
				cState.setInt(3, cParam.m_nTypeId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = 2;
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}
%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateFollowTagCParam cParam = new UpdateFollowTagCParam();
cParam.GetParam(request);

int nRtn = -1;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	UpdateFollowTagC cResults = new UpdateFollowTagC();
	nRtn = cResults.GetResults(cParam);
}
%>{"result":<%=nRtn%>}