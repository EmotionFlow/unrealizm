<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class UpdateMuteKeyword {
	// params
	public int m_nUserId = -1;
	public String m_strDescription = "";

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			m_nUserId			= Common.ToInt(request.getParameter("UID"));
			m_strDescription	= Common.TrimAll(Common.ToString(request.getParameter("DES")));

			m_strDescription = m_strDescription.replace("　", " ").replace("\r\n", " ").replace("\r", " ").replace("\n", " ");
			if(m_strDescription.length()>100) {m_strDescription=m_strDescription.substring(0, 100);}
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

			// update mute keyword
			String strKeywords[] = m_strDescription.split(" ");
			StringBuilder strMuteKeyword = new StringBuilder();
			for(String word : strKeywords) {
				word = word.trim();
				if(!word.isEmpty()) {
					strMuteKeyword.append("-");
					strMuteKeyword.append(word);
					strMuteKeyword.append(" ");
				}
			}

			strSql = "UPDATE users_0000 SET mute_keyword=? WHERE user_id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setString(1, strMuteKeyword.toString());
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

UpdateMuteKeyword cResults = new UpdateMuteKeyword();
cResults.getParam(request);

boolean bRtn = false;
if( cCheckLogin.m_bLogin && cResults.m_nUserId == cCheckLogin.m_nUserId ) {
	bRtn = cResults.getResults(cCheckLogin);
}
%>{"result": <%=(bRtn)?1:0%>}