<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateFollowTagC {
	public static final int FAVO_MAX = 10;
	public static final int OK_INSERT = 1;
	public static final int OK_DELETE = 0;
	public static final int ERR_NOT_LOGIN = -1;
	public static final int ERR_MAX = -2;
	public static final int ERR_UNKNOWN = -99;

	public int m_nUserId = -1;
	public String m_strTagTxt = "";
	public int m_nTypeId = 0;
	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId	= Util.toInt(request.getParameter("UID"));
			m_strTagTxt	= Common.TrimAll(request.getParameter("TXT"));
			m_nTypeId	= Util.toIntN(request.getParameter("TYP"), Common.FOVO_KEYWORD_TYPE_TAG, Common.FOVO_KEYWORD_TYPE_SEARCH);
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int m_nContentsNum = 0;
	public int getResults(CheckLogin checkLogin) {
		if(m_strTagTxt.isEmpty()) return ERR_UNKNOWN;

		int nRtn = ERR_UNKNOWN;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			boolean bFollowing = false;
			// now following check
			strSql ="SELECT * FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nUserId);
			cState.setString(2, m_strTagTxt);
			cState.setInt(3, m_nTypeId);
			cResSet = cState.executeQuery();
			bFollowing = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(!bFollowing) {
				strSql = "SELECT count(*) FROM follow_tags_0000 WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, checkLogin.m_nUserId);
				cResSet = cState.executeQuery();
				if (cResSet.next()) {
					m_nContentsNum = cResSet.getInt(1);
				}
				cResSet.close();cResSet=null;
				cState.close();cState=null;
				if(m_nContentsNum>=FAVO_MAX) return ERR_MAX;

				strSql ="INSERT INTO follow_tags_0000(user_id, tag_txt, type_id) VALUES(?, ?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setString(2, m_strTagTxt);
				cState.setInt(3, m_nTypeId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = OK_INSERT;
			} else {
				strSql ="DELETE FROM follow_tags_0000 WHERE user_id=? AND tag_txt=? AND type_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, m_nUserId);
				cState.setString(2, m_strTagTxt);
				cState.setInt(3, m_nTypeId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = OK_DELETE;
			}
		} catch(Exception e) {
			e.printStackTrace();
			nRtn = ERR_UNKNOWN;
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateFollowTagC cResults = new UpdateFollowTagC();
cResults.getParam(request);

int nRtn = UpdateFollowTagC.ERR_NOT_LOGIN;
if(checkLogin.m_bLogin && cResults.m_nUserId==checkLogin.m_nUserId) {
	nRtn = cResults.getResults(checkLogin);
}
String strMessage = "";
if(nRtn<0) {
	switch(nRtn) {
	case UpdateFollowTagC.ERR_NOT_LOGIN:
		strMessage = _TEX.T("UpdateFollowTagC.ERR_NOT_LOGIN");
		break;
	case UpdateFollowTagC.ERR_MAX:
		strMessage = String.format(_TEX.T("UpdateFollowTagC.ERR_MAX"), UpdateFollowTagC.FAVO_MAX);
		break;
	case UpdateFollowTagC.ERR_UNKNOWN:
	default:
		strMessage = _TEX.T("UpdateFollowTagC.ERR_UNKNOWN");
		break;
	}
}
%>{
"result":<%=nRtn%>,
"message" : "<%=CEnc.E(strMessage.toString())%>"
}