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
String user_id="";
String screen_name="";

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;

ResultSet cResSet = null;
String strSql = "";
boolean bIsExist = false;

// table update or insert
try
{
	OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
	OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");

	String oauth_verifier = request.getParameter("oauth_verifier");
	provider.retrieveAccessToken(consumer, oauth_verifier);
	accessToken = consumer.getToken();
	tokenSecret = consumer.getTokenSecret();

	HttpParameters hp = provider.getResponseParameters();
	user_id = hp.get("user_id").first();
	screen_name = hp.get("screen_name").first();

	Class.forName("org.postgresql.Driver");
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	// select
	strSql = "SELECT flduserid FROM tbloauth WHERE flduserid=? AND fldproviderid=? AND del_flg=False";
	cState = cConn.prepareStatement(strSql);
	cState.setInt(1, checkLogin.m_nUserId);
	cState.setInt(2, Common.TWITTER_PROVIDER_ID);
	cResSet = cState.executeQuery();
	if(cResSet.next()){
		bIsExist = true;
	}
	cResSet.close();cResSet=null;
	cState.close();cState=null;

	if (bIsExist){
		Log.d("TwitterToken Update : " + checkLogin.m_nUserId);
		// update
		strSql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, fldDefaultEnable=true, twitter_user_id=?, twitter_screen_name=? WHERE flduserid=? AND fldproviderid=? AND del_flg=False";
		cState = cConn.prepareStatement(strSql);
		cState.setString(1, consumer.getToken());
		cState.setString(2, consumer.getTokenSecret());
		cState.setString(3, user_id);
		cState.setString(4, screen_name);
		cState.setInt(5, checkLogin.m_nUserId);
		cState.setInt(6, Common.TWITTER_PROVIDER_ID);
		cState.executeUpdate();
	} else {
		Log.d("TwitterToken Insert : " + checkLogin.m_nUserId);
		// insert
		strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?) ";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, checkLogin.m_nUserId);
		cState.setInt(2, Common.TWITTER_PROVIDER_ID);
		cState.setString(3, consumer.getToken());
		cState.setString(4, consumer.getTokenSecret());
		cState.setString(5, user_id);
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
