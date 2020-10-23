<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateDispFollowerLink {
	// params
	public int m_nUserId = -1;
	public int m_nMode = CUser.REACTION_SHOW;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Util.toInt(request.getParameter("UID"));
			m_nMode = Util.toInt(request.getParameter("MID"));
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public int getResults(CheckLogin cCheckLogin) {
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			strSql = "UPDATE users_0000 SET ng_reaction=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nMode);
			cState.setInt(2, cCheckLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cState != null) cState.close();} catch(Exception e) {;}
			try {if(cConn != null) cConn.close();} catch(Exception e) {;}
		}
		return m_nMode;
	}
}%><%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateDispFollowerLink cResults = new UpdateDispFollowerLink();
cResults.getParam(request);

int nMode = CUser.REACTION_SHOW;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	nMode = cResults.getResults(cCheckLogin);
}
%>{"result": <%=nMode%>}