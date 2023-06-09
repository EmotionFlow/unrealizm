<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
int nResult = 0;

CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	nResult = -1;
}

IllustListC results = new IllustListC();
results.getParam(request);

if (checkLogin.m_nUserId!=results.m_nUserId) {
	nResult = -2;
}

results.m_bDispUnPublished = true;

if (!results.getResults(checkLogin, false)) {
	nResult = -2;
}

Map<String, Object> result = null;
ObjectMapper mapper = null;

try {
	result = new HashMap<String, Object>();
	result.put("result", nResult);

	if (nResult == 0) {
		result.put("user_id", results.m_cUser.m_nUserId);
		result.put("page_num", results.m_nPage);
		result.put("content_num", results.m_nContentsNum);
		result.put("content_num_total", results.m_nContentsNumTotal);
		result.put("user_name", results.m_cUser.m_strNickName);
		result.put("profile_icon_image_url", Common.GetUrl(results.m_cUser.m_strFileName));
		result.put("profile_header_image_url", Common.GetUrl(results.m_cUser.m_strHeaderFileName));
		result.put("profile_message", results.m_cUser.m_strProfile);
		result.put("follow_num", results.m_cUser.m_nFollowNum);
		result.put("follower_num", results.m_cUser.m_nFollowerNum);

		String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
				URLEncoder.encode(String.format(_TEX.T("MyIllustListV.TweetMyBox.Tweet.Msg"), results.m_cUser.m_strNickName), "UTF-8"),
				URLEncoder.encode(Common.GetUnrealizmUrl("/"+results.m_cUser.m_nUserId+"/"), "UTF-8"));
		result.put("twitter_link", strTwitterUrl);

		List<String> myTagList = new ArrayList<>();
		for(CTag tag : results.m_vCategoryList){
			myTagList.add(tag.m_strTagTxt);
		}
		result.put("mytag_list", myTagList);

		List<Map<String, Object>> contentList = new ArrayList<>();
		for(CContent content : results.contentList) {
			String strCategory = "";
			for(int nCategoryId : Common.CATEGORY_ID) {
				if (nCategoryId==content.m_nCategoryId) {
					strCategory = _TEX.T(String.format("Category.C%d", nCategoryId));
					break;
				}
			}

			Map<String, Object> content = new HashMap<>();
			content.put("content_id", content.m_nContentId);
			content.put("url", Common.GetUrl(content.m_strFileName));
			content.put("tag_list", content.m_strTagList);
			content.put("description", content.m_strDescription);
			content.put("category", strCategory);
			content.put("category_id", content.m_nCategoryId);
			content.put("open_id", content.m_nOpenId);
			content.put("publish_id", content.m_nPublishId);
			content.put("content_twitter_link", CTweet.generateAfterTweetMsg(content, _TEX));
			content.put("file_num", content.m_nFileNum);
			contentList.add(content);
		}
		result.put("content_list", contentList);
	}

	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(result));
} catch(JsonGenerationException e)  {
	e.printStackTrace();
} finally {
	result = null;
	mapper = null;
}
%>
