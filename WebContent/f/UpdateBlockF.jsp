<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateBlockCParam {
	public int m_nBlockUserId = -1;
	public int m_nUserId = -1;
	public boolean m_bBlock = false;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			cRequest.setCharacterEncoding("UTF-8");
			m_nUserId		= Util.toInt(cRequest.getParameter("UID"));
			m_nBlockUserId	= Util.toInt(cRequest.getParameter("IID"));
			m_bBlock		= (Util.toInt(cRequest.getParameter("CHK"))==1);
		} catch(Exception e) {
			m_nBlockUserId = -1;
			m_nUserId = -1;
			m_bBlock = false;
		}
	}
}

class UpdateBlockC {
	public int GetResults(UpdateBlockCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			if(cParam.m_bBlock) {
				// delete follow
				strSql ="DELETE FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nBlockUserId);
				cState.executeUpdate();
				cState.close();cState=null;
				strSql ="DELETE FROM follows_0000 WHERE user_id=? AND follow_user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nBlockUserId);
				cState.setInt(2, cParam.m_nUserId);
				cState.executeUpdate();
				cState.close();cState=null;

				strSql ="INSERT INTO blocks_0000(user_id, block_user_id) VALUES(?, ?) ON CONFLICT DO NOTHING;";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nBlockUserId);
				cState.executeUpdate();
				cState.close();cState=null;

				nRtn = 1;
			} else {
				strSql ="DELETE FROM blocks_0000 WHERE user_id=? AND block_user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nUserId);
				cState.setInt(2, cParam.m_nBlockUserId);
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

UpdateBlockCParam cParam = new UpdateBlockCParam();
cParam.GetParam(request);

int nRtn = -1;
if( checkLogin.m_bLogin && cParam.m_nUserId == checkLogin.m_nUserId ) {
	UpdateBlockC cResults = new UpdateBlockC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>{"result":<%=nRtn%>}