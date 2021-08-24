<%@page
language="java"
contentType="text/html; charset=UTF-8"%>
<%@page import="java.awt.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="javax.naming.*"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.http.HttpParameters"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin checkLogin = new CheckLogin(request, response);

boolean bResult = false;

//login check
if(!checkLogin.m_bLogin || checkLogin.m_nUserId < 1){
	response.sendRedirect("myurlscheme://deleted");
	return;
}

String accessToken="";
String tokenSecret="";
String twitterUserId ="";
String screen_name="";

Connection cConn = null;
PreparedStatement cState = null;

ResultSet cResSet = null;
String strSql = "";
boolean bIsExist = false;

// table update or insert
try {
	OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
	OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");

	String oauth_verifier = request.getParameter("oauth_verifier");
	provider.retrieveAccessToken(consumer, oauth_verifier);
	accessToken = consumer.getToken();
	tokenSecret = consumer.getTokenSecret();

	HttpParameters hp = provider.getResponseParameters();
	twitterUserId = hp.get("user_id").first();
	screen_name = hp.get("screen_name").first();

	cConn = DatabaseUtil.dataSource.getConnection();

	// select
	strSql = "SELECT 1 FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, checkLogin.m_nUserId);
	cState.setInt(2, Common.TWITTER_PROVIDER_ID);
	cResSet = cState.executeQuery();
	bIsExist = cResSet.next();
	cResSet.close();cResSet=null;
	cState.close();cState=null;

	if (!bIsExist) {
		strSql = "SELECT id FROM tbloauth WHERE flduserid=? AND twitter_user_id=? AND fldproviderid=? AND del_flg=true";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, checkLogin.m_nUserId);
		cState.setString(2, twitterUserId);
		cState.setInt(3, Common.TWITTER_PROVIDER_ID);
		cResSet = cState.executeQuery();
		int id = -1;
		if (cResSet.next()) {
			id = cResSet.getInt(1);
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		if (id > 0) {
			strSql = "UPDATE tbloauth SET del_flg=false WHERE id=?";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, id);
			cState.executeUpdate();
			cState.close();cState=null;
			bIsExist = true;
		}
	}

	if (bIsExist){
		Log.d("TwitterToken Update(api) : " + checkLogin.m_nUserId);
		// update
		strSql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, fldDefaultEnable=true, twitter_user_id=?, twitter_screen_name=? WHERE flduserid=? AND fldproviderid=? AND del_flg=false";
		cState = cConn.prepareStatement(strSql);
		cState.setString(1, accessToken);
		cState.setString(2, tokenSecret);
		cState.setString(3, twitterUserId);
		cState.setString(4, screen_name);
		cState.setInt(5, checkLogin.m_nUserId);
		cState.setInt(6, Common.TWITTER_PROVIDER_ID);
		cState.executeUpdate();
	} else {
		Log.d("TwitterToken Insert(api) : " + checkLogin.m_nUserId);
		// insert
		strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?) ";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, checkLogin.m_nUserId);
		cState.setInt(2, Common.TWITTER_PROVIDER_ID);
		cState.setString(3, accessToken);
		cState.setString(4, tokenSecret);
		cState.setString(5, twitterUserId);
		cState.setString(6, screen_name);
		cState.setString(7, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("Common.Title")+String.format(" https://poipiku.com/%d/", checkLogin.m_nUserId));
		cState.executeUpdate();
	}
	cState.close();cState=null;
	bResult = true;
} catch(Exception e) {
	Log.d(strSql);
	e.printStackTrace();
} finally {
	try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
	try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
response.sendRedirect("myurlscheme://back");
%>
