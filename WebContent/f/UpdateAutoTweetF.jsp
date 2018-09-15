<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

//login check
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

int m_nUserId = Common.ToInt(request.getParameter("ID"));
int m_nAutoTweetWeekDay = Math.min(Math.max(Common.ToInt(request.getParameter("AW")), -1), 6);
int m_nAutoTweetTime = Math.min(Math.max(Common.ToInt(request.getParameter("AT")), -1), 23);
String m_strAutoTweetTxt = Common.TrimAll(Common.ToString(request.getParameter("AD")));
if(m_strAutoTweetTxt.length()>100) {m_strAutoTweetTxt=m_strAutoTweetTxt.substring(0, 100);}

int nRtn = 0;
if(cCheckLogin.m_bLogin && (cCheckLogin.m_nUserId == m_nUserId)) {

	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	String strSql = "";

	try {
		dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();

		strSql = "UPDATE tbloauth SET auto_tweet_weekday=?, auto_tweet_time=?, auto_tweet_desc=?  WHERE flduserid=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nAutoTweetWeekDay);
		cState.setInt(2, m_nAutoTweetTime);
		cState.setString(3, m_strAutoTweetTxt);
		cState.setInt(4, m_nUserId);
		cState.executeUpdate();
		cState.close(); cState=null;
		nRtn = 1;
	} catch(Exception e) {
		Log.d(strSql);
		e.printStackTrace();
	} finally {
		try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
		try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
	}
}
%>{"result":<%=nRtn%>}