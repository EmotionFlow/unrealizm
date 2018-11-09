<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="javax.naming.*"%>
<%@page import="javax.sql.*"%>
<%@page import="oauth.signpost.http.*"%>
<%@page import="oauth.signpost.*"%>
<%@include file="/inner/Common.jsp"%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

boolean bResult = false;
int nUserId = -1;
String strHashPass = "";

String accessToken="";
String tokenSecret="";
String user_id="";
String screen_name="";

DataSource dsPostgres = null;
Connection cConn = null;
PreparedStatement cState = null;
ResultSet cResSet = null;
String strSql = "";

// table update or insert
try {
	OAuthConsumer consumer = (OAuthConsumer) session.getAttribute("consumer");
	OAuthProvider provider = (OAuthProvider) session.getAttribute("provider");
	if(consumer==null) throw(new Exception("consumer error"));
	if(provider==null) throw(new Exception("provider error"));

	String oauth_verifier = request.getParameter("oauth_verifier");
	if(oauth_verifier==null || oauth_verifier.isEmpty()) throw(new Exception("oauth_verifier error"));

	provider.retrieveAccessToken(consumer, oauth_verifier);
	accessToken = consumer.getToken();
	tokenSecret = consumer.getTokenSecret();
	if(accessToken==null || accessToken.isEmpty()) throw(new Exception("accessToken error"));
	if(tokenSecret==null || tokenSecret.isEmpty()) throw(new Exception("tokenSecret error"));

	HttpParameters hp = provider.getResponseParameters();
	if(hp==null) throw(new Exception("hp error"));
	user_id = hp.get("user_id").first();
	if(user_id==null || user_id.isEmpty()) throw(new Exception("user_id error"));
	screen_name = hp.get("screen_name").first();
	if(screen_name==null || screen_name.isEmpty()) throw(new Exception("screen_name error"));

	Class.forName("org.postgresql.Driver");
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();

	// select
	strSql = "SELECT fldUserId FROM tbloauth WHERE fldaccesstoken=? AND fldsecrettoken=? ORDER BY fldUserId LIMIT 1";
	cState = cConn.prepareStatement(strSql);
	cState.setString(1, accessToken);
	cState.setString(2, tokenSecret);
	cResSet = cState.executeQuery();
	if(cResSet.next()) {
		nUserId = cResSet.getInt("fldUserId");
	}
	cResSet.close();cResSet=null;
	cState.close();cState=null;

	if (nUserId>0){	// Login
		Log.d("Login : " + nUserId);
		String strPassword = "";
		strSql = "SELECT * FROM users_0000 WHERE user_id=?";
		cState = cConn.prepareStatement(strSql);
		cState.setInt(1, nUserId);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			nUserId		= cResSet.getInt("user_id");
			strHashPass 	= Common.ToString(cResSet.getString("hash_password"));
			strPassword 	= Common.ToString(cResSet.getString("password"));
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		if(nUserId>0) {
			if(strHashPass.isEmpty()) {
				strHashPass = Util.getHashPass(strPassword);
				// LKをDB登録
				strSql = "UPDATE users_0000 SET hash_password=? WHERE user_id=?";
				cState = cConn.prepareStatement(strSql);
				cState.setString(1, strHashPass);
				cState.setInt(2, nUserId);
				cState.executeUpdate();
				cState.close();cState=null;
			}
		} else {
			Log.d("Login error : no user : " + nUserId);
		}

		Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);
		cLK.setMaxAge(Integer.MAX_VALUE);
		cLK.setPath("/");
		response.addCookie(cLK);

		bResult = true;
	} else {		// Regist
		Log.d("Regist start");
		String strPassword = RandomStringUtils.randomAlphanumeric(16);
		strHashPass = Util.getHashPass(strPassword);
		String strEmail = RandomStringUtils.randomAlphanumeric(16);

		// Lang Id
		int nLangId=1;
		Cookie[] cookies = request.getCookies();
		if (cookies != null){
			for(int i=0; i<cookies.length; i++){
				if(cookies[i].getName().equals("LANG")){
					String strLang = cookies[i].getValue();
					nLangId = (strLang.equals("en"))?0:1;
				}
			}
		}

		// User名被りチェック
		boolean bUserName = false;
		String strUserName = screen_name;
		strSql = "SELECT * FROM users_0000 WHERE nickname=?";
		cState = cConn.prepareStatement(strSql);
		cState.setString(1, strUserName);
		cResSet = cState.executeQuery();
		bUserName = cResSet.next();
		cResSet.close();cResSet=null;
		for(int nCnt=0; bUserName; nCnt++) {
			strUserName = String.format("%s_%d", screen_name, nCnt);
			cState.setString(1, strUserName);
			cResSet = cState.executeQuery();
			bUserName = cResSet.next();
			cResSet.close();cResSet=null;
		}
		cState.close();cState=null;

		// User作成
		strSql = "INSERT INTO users_0000(nickname, password, hash_password, email, lang_id) VALUES(?, ?, ?, ?, ?)";
		cState = cConn.prepareStatement(strSql);
		cState.setString(1, strUserName);
		cState.setString(2, strPassword);
		cState.setString(3, strHashPass);
		cState.setString(4, strEmail);
		cState.setInt(5, nLangId);
		cState.executeUpdate();
		cState.close();cState=null;

		// User ID 取得
		strSql = "SELECT * FROM users_0000 WHERE nickname=? AND password=?";
		cState = cConn.prepareStatement(strSql);
		cState.setString(1, strUserName);
		cState.setString(2, strPassword);
		cResSet = cState.executeQuery();
		if(cResSet.next()) {
			nUserId = cResSet.getInt("user_id");
		}
		cResSet.close();cResSet=null;
		cState.close();cState=null;

		if(nUserId>0) {
			// tbloauthに登録
			strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_weekday, auto_tweet_time, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?, ?, ?) ";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, nUserId);
			cState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cState.setString(3, accessToken);
			cState.setString(4, tokenSecret);
			cState.setString(5, user_id);
			cState.setString(6, screen_name);
			cState.setInt(7, -1);
			cState.setInt(8, -1);
			cState.setString(9, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("THeader.Title")+String.format(" https://poipiku.com/%d/", nUserId));
			cState.executeUpdate();
			cState.close();cState=null;


			Cookie cLK = new Cookie("POIPIKU_LK", strHashPass);
			cLK.setMaxAge(Integer.MAX_VALUE);
			cLK.setPath("/");
			response.addCookie(cLK);

			bResult = true;

			Log.d("Regist : " + nUserId);
		}
	}
} catch(Exception e) {
	Log.d(strSql);
	Log.d(e.getMessage());
} finally {
	try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
	try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=/MyHomeV.jsp" />
		<script>
		$(function(){
			sendObjectMessage("restart");
		});
		</script>
	</head>

	<body>
		<div class="Wrapper" style="text-align: center;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="/MyHomeV.jsp">
			<%if(bResult) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</div><!--Wrapper-->
	</body>
</html>
