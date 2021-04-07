<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	request.setCharacterEncoding("UTF-8");

//login check
CheckLogin checkLogin = new CheckLogin(request, response);

int m_nUserId = Util.toInt(request.getParameter("ID"));
int m_nAutoTweetWeekDay = Util.toIntN(request.getParameter("AW"), 0, 6);
int m_nAutoTweetTime = Util.toIntN(request.getParameter("AT"), -1, 23);
String m_strAutoTweetTxt = Common.TrimAll(Util.toString(request.getParameter("AD")));
int m_nAutoTweetThumbNum = Util.toIntN(request.getParameter("ATN"), 0, 9);
if(m_strAutoTweetTxt.length()>100) {m_strAutoTweetTxt=m_strAutoTweetTxt.substring(0, 100);}

int nRtn = 0;
if(checkLogin.m_bLogin && (checkLogin.m_nUserId == m_nUserId)) {

	DataSource dsPostgres = null;
	Connection cConn = null;
	PreparedStatement cState = null;
	String strSql = "";

	try {
		dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
		cConn = dsPostgres.getConnection();

		strSql = "UPDATE tbloauth SET auto_tweet_weekday=?, auto_tweet_time=?, auto_tweet_desc=?, auto_tweet_thumb_num=?  WHERE flduserid=? AND del_flg=False";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, m_nAutoTweetWeekDay);
		cState.setInt(2, m_nAutoTweetTime);
		cState.setString(3, m_strAutoTweetTxt);
		cState.setInt(4, m_nAutoTweetThumbNum);
		cState.setInt(5, m_nUserId);
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