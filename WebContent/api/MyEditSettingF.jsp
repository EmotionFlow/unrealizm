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

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	nResult = -1;
}

//パラメータの取得
MyEditSettingC results = new MyEditSettingC();
results.getParam(request);

//検索結果の取得
if (!results.getResults(checkLogin)) {
	nResult = -2;
}

//JSON元データを格納する連想配列
Map<String, Object> user = null;
Map<String, Object> twitter = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	user = new HashMap<String, Object>();
	user.put("result", nResult);
	user.put("user_id", checkLogin.m_nUserId);
	user.put("premium_id", checkLogin.m_nPassportId);
	user.put("passport_id", checkLogin.m_nPassportId);

	if (nResult == 0) {
		//Twitterの情報
		if (results.m_cUser.m_strTwitterScreenName.isEmpty()) {
			user.put("twitter_link_info", null);
		} else {
			twitter = new HashMap<String, Object>();
			if (results.m_cUser.m_nAutoTweetWeekDay == -1 && results.m_cUser.m_nAutoTweetTime == -1) {
				twitter.put("tweet_regularly_enabled", false);
			} else {
				twitter.put("tweet_regularly_enabled", true);
			}
			twitter.put("twitter_account_name", results.m_cUser.m_strTwitterScreenName);
			twitter.put("tweet_day", results.m_cUser.m_nAutoTweetWeekDay);
			twitter.put("tweet_time", results.m_cUser.m_nAutoTweetTime);
			twitter.put("default_tweet_message", results.m_cUser.m_strAutoTweetDesc);
			twitter.put("tweet_with_thumbnail_enabled", results.m_cUser.m_nAutoTweetThumbNum);
			user.put("twitter_link_info", twitter);
		}

		user.put("user_name", results.m_cUser.m_strNickName);
		user.put("profile_icon_image_url", Common.GetUrl(results.m_cUser.m_strFileName));
		user.put("profile_message", results.m_cUser.m_strProfile);
		if(results.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {
			user.put("profile_header_image_url", "");
		} else {
			user.put("profile_header_image_url", Common.GetUrl(results.m_cUser.m_strHeaderFileName));
		}
		if(results.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {
			user.put("profile_bg_image_url", "");
		} else {
			user.put("profile_bg_image_url", Common.GetUrl(results.m_cUser.m_strBgFileName));
		}
		user.put("ng_ad_mode", results.m_cUser.m_nAdMode);
		user.put("ng_download", results.m_cUser.m_nDownload);
		user.put("ng_reaction", results.m_cUser.m_nReaction);
		user.put("mute_keyword", results.m_cUser.m_strMuteKeyword);
		user.put("email_address", results.m_cUser.m_strEmail);
		user.put("new_email_address", results.m_strNewEmail);
		user.put("email_address_confirmed", !results.m_bUpdate);
		user.put("terms_of_service_url", "/RuleS.jsp");
		user.put("guidelines_url", "/GuideLineAppV.jsp");
		user.put("privacy_policy_url", "/PrivacyPolicyS.jsp");
		user.put("info_account_url", "/IllustListAppV.jsp?ID=2");
		user.put("official_twitter_url", "https://twitter.com/pipajp");
		user.put("inquiry_url", "https://cs.pipa.jp/InquiryAppV.jsp");
	}

	//JSONに変換して出力
	mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(user);
	out.print(json);
	//Log.d(json);
} catch(JsonGenerationException e) {
	e.printStackTrace();
} finally {
	user = null;
	twitter = null;
	mapper = null;
}
%>
