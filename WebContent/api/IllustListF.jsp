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
IllustListC cResults = new IllustListC();
cResults.getParam(request);

//検索結果の取得
if (checkLogin.m_nUserId!=cResults.m_nUserId || !cResults.getResults(checkLogin, false)) {
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
		user.put("user_id", cResults.m_cUser.m_nUserId);
		user.put("page_num", cResults.m_nPage);
		user.put("content_num", cResults.m_nContentsNum);
		user.put("content_num_total", cResults.m_nContentsNumTotal);
		user.put("user_name", cResults.m_cUser.m_strNickName);
		user.put("profile_icon_image_url", Common.GetUrl(cResults.m_cUser.m_strFileName));
		user.put("profile_header_image_url", Common.GetUrl(cResults.m_cUser.m_strHeaderFileName));
		user.put("profile_message", cResults.m_cUser.m_strProfile);
		user.put("follow_num", cResults.m_cUser.m_nFollowNum);
		user.put("follower_num", cResults.m_cUser.m_nFollowerNum);

		//Twitterリンク
		String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
				URLEncoder.encode(String.format("%s%s %s #%s",
						cResults.m_cUser.m_strNickName,
						_TEX.T("Twitter.UserAddition"),
						String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
						_TEX.T("Common.Title")), "UTF-8"),
				URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
		user.put("twitter_link", strTwitterUrl);

		//画像の情報(配列)
		List<Map<String, Object>> imglist = new ArrayList<Map<String, Object>>();
		for(CContent cContent : cResults.m_vContentList) {
			//カテゴリ名設定
			String strCategory = "";
			for(int nCategoryId : Common.CATEGORY_ID) {
				if (nCategoryId==cContent.m_nCategoryId) {
					strCategory = _TEX.T(String.format("Category.C%d", nCategoryId));
					break;
				}
			}

			Map<String, Object> img = new HashMap<String, Object>();
			img.put("content_id", cContent.m_nContentId);
			img.put("url", Common.GetUrl(cContent.m_strFileName));
			img.put("tag_list", cContent.m_strTagList);
			img.put("description", cContent.m_strDescription);
			img.put("category", strCategory);
			img.put("category_id", cContent.m_nCategoryId);
			img.put("publish_id", cContent.m_nPublishId);
			img.put("content_twitter_link", CTweet.generateAfterTweerMsg(cContent, _TEX));
			img.put("file_num", cContent.m_nFileNum);
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
