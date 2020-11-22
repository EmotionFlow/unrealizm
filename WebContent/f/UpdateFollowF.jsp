<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateFollowCParam {
	public int m_nFollowedUserId = -1;
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nFollowedUserId	= Util.toInt(cRequest.getParameter("IID"));
			m_nUserId			= Util.toInt(cRequest.getParameter("UID"));
		} catch(Exception e) {
			m_nFollowedUserId = -1;
			m_nUserId = -1;
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


			boolean bCanFollow = true;
			// blocking
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nFollowedUserId);
			cResSet = cState.executeQuery();
			bCanFollow = !cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			// blocked
			strSql = "SELECT * FROM blocks_0000 WHERE user_id=? AND block_user_id=? LIMIT 1";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nFollowedUserId);
			cState.setInt(2, cParam.m_nUserId);
			cResSet = cState.executeQuery();
			bCanFollow = !cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			boolean bFollowing = false;
			// now following check
			strSql ="SELECT * FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nFollowedUserId);
			cResSet = cState.executeQuery();
			bFollowing = cResSet.next();
			cResSet.close();cResSet=null;
			cState.close();cState=null;


			if(bCanFollow && !bFollowing) {
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
}%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateFollowCParam cParam = new UpdateFollowCParam();
cParam.GetParam(request);

int nRtn = -1;
if( checkLogin.m_bLogin && cParam.m_nUserId == checkLogin.m_nUserId ) {
	UpdateFollowC cResults = new UpdateFollowC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>{"result":<%=nRtn%>}