<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateNotifyCParam {
	public int m_nUserId = -1;

	public void GetParam(HttpServletRequest cRequest) {
		try {
			//cRequest.setCharacterEncoding("UTF-8");
		} catch(Exception e) {
			m_nUserId = -1;
		}
	}
}

class UpdateNotifyC {
	public boolean GetResults(UpdateNotifyCParam cParam) {
		String strSql = "";
		boolean bRtn = false;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;

		try {
			Class.forName("org.postgresql.Driver");
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			bRtn = true;	// 以下エラーが有ってもOK.表示は行う

			// Update Last Check Time
			strSql = "UPDATE users_0000 SET last_check_date=CURRENT_TIMESTAMP, last_notify_date=CURRENT_TIMESTAMP WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.executeUpdate();
			cState.close();cState=null;

		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return bRtn;
	}
}
%><%
CheckLogin cCheckLogin = new CheckLogin(request, response);

UpdateNotifyCParam cParam = new UpdateNotifyCParam();
cParam.GetParam(request);
cParam.m_nUserId = cCheckLogin.m_nUserId;

UpdateNotifyC cResults = new UpdateNotifyC();
boolean bRtn = cResults.GetResults(cParam);
%>{"result":0}