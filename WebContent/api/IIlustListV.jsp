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
	nResult = -1;
}

//パラメータの取得
IllustListC cResults = new IllustListC();
cResults.getParam(request);

//検索結果の取得
if (!cResults.getResults(cCheckLogin, false)) {
	nResult = -2;
}

//JSON元データを格納する連想配列
Map<String, Object> user = null;
ObjectMapper mapper = null;

try {
	String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
			URLEncoder.encode(String.format("%s%s %s #%s",
					cResults.m_cUser.m_strNickName,
					_TEX.T("Twitter.UserAddition"),
					String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
					_TEX.T("Common.Title")), "UTF-8"),
			URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));

	//ユーザの情報
	user = new HashMap<String, Object>();
	user.put("result", nResult);
	user.put("page_num", cResults.m_nPage);
	user.put("content_num", cResults.m_nContentsNumTotal);
	user.put("user_id", cResults.m_cUser.m_nUserId);
	user.put("user_name", Common.ToStringHtml(cResults.m_cUser.m_strNickName));
	user.put("profile_icon_image_url", Common.GetUrl(cResults.m_cUser.m_strFileName));
	user.put("profile_header_image_url", Common.GetUrl(cResults.m_cUser.m_strHeaderFileName));
	user.put("profile_message", Common.ToStringHtml(cResults.m_cUser.m_strProfile));
	user.put("follow_num", cResults.m_cUser.m_nFollowNum);
	user.put("follower_num", cResults.m_cUser.m_nFollowerNum);
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
		img.put("tags", Common.ToStringHtml(cContent.m_strTagList));
		img.put("description", Common.ToStringHtml(cContent.m_strDescription));
		img.put("category", strCategory);
		img.put("content_twitter_link", CTweet.generateIllustMsgUrl(cContent, _TEX));
		imglist.add(img);
	}
	user.put("uploaded_image_infos", imglist);

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(user));
} catch(JsonGenerationException e)  {
	strDebug = e.toString();
} finally {
	user = null;
	mapper = null;
}
%>
