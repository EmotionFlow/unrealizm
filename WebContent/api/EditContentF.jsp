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
IllustViewC results = new IllustViewC();
results.getParam(request);

//検索結果の取得
if (checkLogin.m_nUserId!=results.m_nUserId || !results.getResults(checkLogin)) {
	nResult = -2;
}

// V2 -> V1 convert
if (results.content.m_nOpenId == Common.OPEN_ID_HIDDEN && !results.content.m_bLimitedTimePublish) {
	results.content.m_nPublishId = Common.PUBLISH_ID_HIDDEN;
} else if (results.content.m_nPublishId == Common.PUBLISH_ID_ALL && results.content.isPasswordEnabled()) {
	results.content.m_nPublishId = Common.PUBLISH_ID_PASS;
}

//JSON元データを格納する連想配列
Map<String, Object> content = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	content = new HashMap<String, Object>();
	content.put("result", nResult);

	if (nResult == 0) {
		content.put("user_id", results.m_cUser.m_nUserId);
		content.put("content_id", results.m_nContentId);
		content.put("category_id", results.content.m_nCategoryId);
		content.put("publish_id", results.content.m_nPublishId);
		content.put("description", results.content.m_strDescription);
		content.put("tag_list", results.content.m_strTagList);
		content.put("password", results.content.m_strPassword);
		content.put("upload_date", results.content.m_timeUploadDate);
		content.put("file_name", results.content.m_strFileName);
		content.put("file_num", results.content.m_nFileNum);

		//画像の情報(配列)
		List<Map<String, Object>> filelist = new ArrayList<Map<String, Object>>();
		for(CContentAppend content : results.content.m_vContentAppend) {
			Map<String, Object> file = new HashMap<String, Object>();
			file.put("append_id", content.m_nAppendId);
			file.put("file_name", content.m_strFileName);
			file.put("upload_date", content.m_timeUploadDate);
			filelist.add(file);
		}
		content.put("file_list", filelist);
	}

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(content));
} catch(JsonGenerationException e)  {
	e.printStackTrace();
} finally {
	content = null;
	mapper = null;
}
%>
