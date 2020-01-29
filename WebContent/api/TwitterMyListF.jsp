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
<%@page import="twitter4j.UserList"%>
<%@page import="jp.pipa.poipiku.util.CTweet"%>
<%@include file="/inner/Common.jsp"%>
<%
int nResult = 0;

//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) {
	nResult = -1;
}

//パラメータの取得
int m_nUserId = Common.ToInt(request.getParameter("ID"));

//認証
if (cCheckLogin.m_nUserId!=m_nUserId) {
	nResult = -2;
}

//twitter連携確認
CTweet cTweet = new CTweet();
if (!cTweet.GetResults(m_nUserId)) {
    nResult = -101;
}

//リスト取得
if (!cTweet.GetMyOpenLists()) {
    nResult = -102;
}

//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
    root.put("result", 0);

	if (nResult == 0) {
        //twitter list情報(配列)
		List<Map<String, Object>> twitterListList = new ArrayList<Map<String, Object>>();
		for(UserList u : cTweet.m_listOpenList) {
			Map<String, Object> twitterList = new HashMap<String, Object>();
			twitterList.put("id", u.getId());
			twitterList.put("name", u.getName());
			twitterListList.add(twitterList);
		}
		root.put("twitter_open_list", twitterListList);
	} else {
		List<Map<String, Object>> twitterListList = new ArrayList<Map<String, Object>>();
		root.put("twitter_open_list", twitterListList);
	}

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch(JsonGenerationException e)  {
    e.printStackTrace();
} finally {
	root = null;
	mapper = null;
}
%>
