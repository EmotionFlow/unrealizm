<%@page
language="java"
contentType="text/html; charset=UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="javax.sql.*"%>
<%@page import="javax.naming.*"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.http.HttpParameters"%>
<%@include file="/inner/Common.jsp"%>

<%!
enum Result {
	UNDEF, OK, LINKED_OTHER_POIPIKU_ID, ERROR
}
%>
<%
request.setCharacterEncoding("UTF-8");
CheckLogin cCheckLogin = new CheckLogin(request, response);

Result result = Result.UNDEF;

//login check
if(!cCheckLogin.m_bLogin || cCheckLogin.m_nUserId < 1){
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

String accessToken="";
String tokenSecret="";
String twitter_user_id ="";
String screen_name="";

DataSource dsPostgres = null;
Connection cConn = null;
Statement cState = null;
PreparedStatement cPreState = null;

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
	twitter_user_id = hp.get("user_id").first();
	screen_name = hp.get("screen_name").first();

	Class.forName("org.postgresql.Driver");
	dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
	cConn = dsPostgres.getConnection();
	cState = cConn.createStatement();

	// 他のポイピクアカウントがこのTwitterアカウントと紐づいてるかを検索
	strSql = "SELECT flduserid FROM tbloauth WHERE flduserid<>? AND twitter_user_id=?";
	cPreState = cConn.prepareStatement(strSql);
	cPreState.setInt(1, cCheckLogin.m_nUserId);
	cPreState.setString(2, twitter_user_id);
	cResSet = cPreState.executeQuery();
	if(cResSet.next()){
		result = Result.LINKED_OTHER_POIPIKU_ID;
	} else {
		// select
		strSql = String.format(
				"SELECT flduserid FROM tbloauth WHERE flduserid=%d AND fldproviderid=%d",
				cCheckLogin.m_nUserId,
				Common.TWITTER_PROVIDER_ID
		);
		cResSet = cState.executeQuery(strSql);
		if(cResSet.next()){
			bIsExist = true;
		}
		cResSet.close();

		if (bIsExist){
			Log.d("TwitterToken Update : " + cCheckLogin.m_nUserId);
			// update
			strSql = "UPDATE tbloauth SET fldaccesstoken=?, fldsecrettoken=?, fldDefaultEnable=true, twitter_user_id=?, twitter_screen_name=? WHERE flduserid=? AND fldproviderid=?";
			cPreState = cConn.prepareStatement(strSql);
			cPreState.setString(1, consumer.getToken());
			cPreState.setString(2, consumer.getTokenSecret());
			cPreState.setString(3, twitter_user_id);
			cPreState.setString(4, screen_name);
			cPreState.setInt(5, cCheckLogin.m_nUserId);
			cPreState.setInt(6, Common.TWITTER_PROVIDER_ID);
			cPreState.executeUpdate();
		} else {
			Log.d("TwitterToken Insert : " + cCheckLogin.m_nUserId);
			// insert
			strSql = "INSERT INTO tbloauth(flduserid, fldproviderid, fldDefaultEnable, fldaccesstoken, fldsecrettoken, twitter_user_id, twitter_screen_name, auto_tweet_weekday, auto_tweet_time, auto_tweet_desc) VALUES(?, ?, true, ?, ?, ?, ?, ?, ?, ?) ";
			cPreState = cConn.prepareStatement(strSql);
			cPreState.setInt(1, cCheckLogin.m_nUserId);
			cPreState.setInt(2, Common.TWITTER_PROVIDER_ID);
			cPreState.setString(3, consumer.getToken());
			cPreState.setString(4, consumer.getTokenSecret());
			cPreState.setString(5, twitter_user_id);
			cPreState.setString(6, screen_name);
			cPreState.setInt(7, -1);
			cPreState.setInt(8, -1);
			cPreState.setString(9, _TEX.T("EditSettingV.Twitter.Auto.AutoTxt")+_TEX.T("Common.Title")+String.format(" https://poipiku.com/%d/", cCheckLogin.m_nUserId));
			cPreState.executeUpdate();
		}
		cPreState.close();cPreState=null;
		result = Result.OK;
	}

} catch(Exception e) {
	Log.d(strSql);
	e.printStackTrace();
	result = Result.ERROR;
} finally {
	try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
	try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
	try{if(cPreState!=null){cPreState.close();cPreState=null;}}catch(Exception e){;}
	try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
}

String strNextContextPath = "";
if(result==Result.OK){
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER";
}else if(result==Result.LINKED_OTHER_POIPIKU_ID){
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER&ERR=TW_LINKED";
}else{
	strNextContextPath = "/MyEditSettingPcV.jsp?MENUID=TWITTER&ERR=OTHER";
}

response.sendRedirect(Common.GetPoipikuUrl(strNextContextPath));

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("EditSettingV.Twitter")%></title>
		<meta http-equiv="refresh" content="3;URL=<%=strNextContextPath%>" />
		<style>
		.AnalogicoInfo {display: none;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper" style="text-align: center; margin: 150px auto;">
			<p><%=_TEX.T("EditSettingV.Twitter")%></p>
			<a href="<%=strNextContextPath%>">
			<%if(result==Result.OK) {%>
			<%=_TEX.T("RegistUserV.UpdateComplete")%>
			<%} else {%>
			<%=_TEX.T("RegistUserV.UpdateError")%>
			<%}%>
			</a>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
