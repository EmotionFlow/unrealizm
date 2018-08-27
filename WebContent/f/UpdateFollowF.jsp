<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateFollowCParam {
	public int m_nFollowedUserId = -1;
	public int m_nUserId = -1;
	public boolean m_bFollow = false;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nFollowedUserId	= Common.ToInt(cRequest.getParameter("IID"));
			m_nUserId			= Common.ToInt(cRequest.getParameter("UID"));
			m_bFollow			= (Common.ToInt(cRequest.getParameter("CHK"))==1);
		} catch(Exception e) {
			m_nFollowedUserId = -1;
			m_nUserId = -1;
			m_bFollow = false;
		}
	}
}

class UpdateFollowC {
	public int GetResults(UpdateFollowCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			// blocking
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nFollowedUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cParam.m_bFollow = false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// blocked
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nFollowedUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			if(cResSet.next()) {
				cParam.m_bFollow = false;
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(cParam.m_bFollow) {
				strSql ="INSERT INTO follows_0000(user_id, follow_user_id) VALUES(?, ?)";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nFollowedUserId);
				cState.executeUpdate();
				cState.close();cState=null;
				nRtn = 1;
			} else {
				strSql ="DELETE FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nFollowedUserId);
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
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

UpdateFollowCParam cParam = new UpdateFollowCParam();
cParam.GetParam(request);

int nRtn = -1;
if( cCheckLogin.m_bLogin && cParam.m_nUserId == cCheckLogin.m_nUserId ) {
	UpdateFollowC cResults = new UpdateFollowC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>{"result":<%=nRtn%>}