<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateFollowerLink {
	// params
	public int m_nUserId = -1;
	public int m_nDisp = 0;

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId = Common.ToInt(request.getParameter("UID"));
			m_nDisp += Common.ToInt(request.getParameter("NB1"))>0?1:0;
			m_nDisp += 2;
			m_nDisp += 4;
			m_nDisp += 8;
			m_nDisp += 16;
			m_nDisp += 32;
			//m_nDisp += Common.ToInt(request.getParameter("NB2"))>0?2:0;
			//m_nDisp += Common.ToInt(request.getParameter("NB3"))>0?4:0;
			//m_nDisp += Common.ToInt(request.getParameter("NB4"))>0?8:0;
			//m_nDisp += Common.ToInt(request.getParameter("NB5"))>0?16:0;
			//m_nDisp += Common.ToInt(request.getParameter("NB6"))>0?32:0;
			Log.d("m_nDisp:"+m_nDisp);
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}

	public boolean getResults(CheckLogin cCheckLogin) {
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		String strSql = "";

		try {
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();


			strSql = "UPDATE users_0000 SET mail_comment=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, m_nDisp);
			cState.setInt(2, cCheckLogin.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;
			bRtn = true;
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			try {if(cState != null) cState.close();} catch(Exception e) {;}
			try {if(cConn != null) cConn.close();} catch(Exception e) {;}
		}
		return bRtn;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

UpdateFollowerLink cResults = new UpdateFollowerLink();
cResults.getParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	bRtn = cResults.getResults(cCheckLogin);
}
%>{"result": <%=(bRtn)?1:0%>}