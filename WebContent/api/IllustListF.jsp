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
IllustListC results = new IllustListC();
results.getParam(request);

//検索結果の取得
if (checkLogin.m_nUserId!=results.m_nUserId || !results.getResults(checkLogin, false)) {
	nResult = -2;
}

//JSON元データを格納する連想配列
Map<String, Object> user = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	user = new HashMap<String, Object>();
	user.put("result", nResult);

	if (nResult == 0) {
		user.put("user_id", results.m_cUser.m_nUserId);
		user.put("page_num", results.m_nPage);
		user.put("content_num", results.m_nContentsNum);
		user.put("content_num_total", results.m_nContentsNumTotal);
		user.put("user_name", results.m_cUser.m_strNickName);
		user.put("profile_icon_image_url", Common.GetUrl(results.m_cUser.m_strFileName));
		user.put("profile_header_image_url", Common.GetUrl(results.m_cUser.m_strHeaderFileName));
		user.put("profile_message", results.m_cUser.m_strProfile);
		user.put("follow_num", results.m_cUser.m_nFollowNum);
		user.put("follower_num", results.m_cUser.m_nFollowerNum);

		//Twitterリンク
		String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
				URLEncoder.encode(String.format("%s%s %s #%s",
						results.m_cUser.m_strNickName,
						_TEX.T("Twitter.UserAddition"),
						String.format(_TEX.T("Twitter.UserPostNum"), results.m_nContentsNumTotal),
						_TEX.T("Common.HashTag")), "UTF-8"),
				URLEncoder.encode("https://unrealizm.com/"+results.m_cUser.m_nUserId+"/", "UTF-8"));
		user.put("twitter_link", strTwitterUrl);

		//画像の情報(配列)
		List<Map<String, Object>> imglist = new ArrayList<Map<String, Object>>();
		for(CContent content : results.contentList) {
			//カテゴリ名設定
			String strCategory = "";
			for(int nCategoryId : Common.CATEGORY_ID) {
				if (nCategoryId==content.m_nCategoryId) {
					strCategory = _TEX.T(String.format("Category.C%d", nCategoryId));
					break;
				}
			}

			Map<String, Object> img = new HashMap<String, Object>();
			img.put("content_id", content.m_nContentId);
			img.put("url", Common.GetUrl(content.m_strFileName));
			img.put("tag_list", content.m_strTagList);
			img.put("description", content.m_strDescription);
			img.put("category", strCategory);
			img.put("category_id", content.m_nCategoryId);
			img.put("publish_id", content.m_nPublishId);
			img.put("content_twitter_link", CTweet.generateAfterTweetMsg(content, _TEX));
			img.put("file_num", content.m_nFileNum);
			imglist.add(img);
		}
		user.put("content_list", imglist);
	}

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(user));
} catch(JsonGenerationException e)  {
	e.printStackTrace();
} finally {
	user = null;
	mapper = null;
}
%>
