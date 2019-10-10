<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
int nResult = 0;
String strDebug = "";

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) {
	nResult = 1;
}

//パラメータの取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.GetParam(request);

//検索結果の取得
if (!cResults.GetResults(cCheckLogin)) {
	nResult = 2;
}

//JSON元データを格納する連想配列
Map<String, Object> user = null;
Map<String, Object> twitter = null;
ObjectMapper mapper = null;

try {
	//Twitterの情報
	user = new HashMap<String, Object>();
	if (cResults.m_cUser.m_strTwitterScreenName.isEmpty()) {
		user.put("twitter_link_info", null);
	} else {
		twitter = new HashMap<String, Object>();
		twitter.put("twitter_account_name", Common.ToStringHtml(cResults.m_cUser.m_strTwitterScreenName));
		twitter.put("tweet_regularly_enabled", cResults.m_cUser.m_bTweet);
		twitter.put("tweet_day", cResults.m_cUser.m_nAutoTweetWeekDay);
		twitter.put("tweet_time", cResults.m_cUser.m_nAutoTweetTime);
		twitter.put("default_tweet_message", Common.ToStringHtmlTextarea(cResults.m_cUser.m_strAutoTweetDesc));
		twitter.put("tweet_with_thumbnail_enabled", cResults.m_cUser.m_nAutoTweetThumbNum);
		user.put("twitter_link_info", twitter);
	}

	//ユーザの情報
	user.put("result", nResult);
	user.put("user_id", cResults.m_cUser.m_nUserId);
	user.put("user_name", Common.ToStringHtml(cResults.m_cUser.m_strNickName));
	user.put("profile_icon_image_url", Common.ToStringHtml(cResults.m_cUser.m_strFileName));
	user.put("profile_header_image_url", Common.ToStringHtml(cResults.m_cUser.m_strHeaderFileName));
	user.put("profile_message", Common.ToStringHtml(cResults.m_cUser.m_strProfile));
	user.put("mute_keyword", Common.ToStringHtml(cResults.m_cUser.m_strMuteKeyword));
	user.put("reaction_enabled", cResults.m_cUser.m_nReaction);
	user.put("email_address", Common.ToStringHtmlTextarea(cResults.m_cUser.m_strEmail));
	user.put("email_address_confirmed", !cResults.m_bUpdate);
	user.put("terms_of_service_url", "/RuleS.jsp");
	user.put("guidelines_url", "/GuideLineV.jsp");
	user.put("privacy_policy_url", "/PrivacyPolicyS.jsp");
	user.put("official_twitter_url", "https://twitter.com/pipajp");

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(user));
} catch(JsonGenerationException e)  {
	strDebug = e.toString();
} finally {
	user = null;
	twitter = null;
	mapper = null;
}
%>
