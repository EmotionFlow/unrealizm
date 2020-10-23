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
CTweet cTweet = new CTweet();

PROCESS: {
	//login check
	CheckLogin cCheckLogin = new CheckLogin(request, response);
	if(!cCheckLogin.m_bLogin) {
		nResult = -1;
		break PROCESS;
	}

	//パラメータの取得
	int m_nUserId = Util.toInt(request.getParameter("ID"));

	Log.d(String.format("userid: %d", m_nUserId));

	//認証
	if (cCheckLogin.m_nUserId!=m_nUserId) {
		nResult = -2;
		break PROCESS;
	}

	//twitter連携確認
	if (!cTweet.GetResults(m_nUserId)) {
		nResult = -101;
		break PROCESS;
	}

	//リスト取得
	int r = cTweet.GetMyOpenLists();
	if (r != CTweet.OK) {
		if (r == CTweet.ERR_RATE_LIMIT_EXCEEDED){
	nResult = -102;
		} else if (r == CTweet.ERR_INVALID_OR_EXPIRED_TOKEN){
	nResult = -103;
		} else {
	nResult = r;
		}
		break PROCESS;
	}
}


//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
    root.put("result", nResult);

	if (nResult == 0) {
        //twitter list情報(配列)
		List<Map<String, Object>> twitterListList = new ArrayList<Map<String, Object>>();
		for(UserList u : cTweet.m_listOpenList) {
	Map<String, Object> twitterList = new HashMap<String, Object>();
	twitterList.put("id", Long.toString(u.getId()));
	twitterList.put("name", u.getName());
	twitterListList.add(twitterList);
		}
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
