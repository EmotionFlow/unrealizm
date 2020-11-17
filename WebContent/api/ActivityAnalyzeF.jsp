<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
// login check
CheckLogin checkLogin = new CheckLogin(request, response);

//結果の取得
ActivityAnalyzeC activityAnalyzeC = new ActivityAnalyzeC();
// パラメータの取得
activityAnalyzeC.getParam(request);
// DB検索
int result = activityAnalyzeC.getResults(checkLogin);

//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
		root.put("result", result);

	if (result == ActivityAnalyzeC.OK) {
		root.put("user_id", checkLogin.m_nUserId);
		root.put("content_num", activityAnalyzeC.activityInfos.size());

		//リアクション情報(配列)
		List<Map<String, Object>> reactionList = new ArrayList<Map<String, Object>>();
		for(ActivityAnalyzeC.ActivityInfo activityInfo : activityAnalyzeC.activityInfos) {
			Map<String, Object> reaction = new HashMap<String, Object>();
			reaction.put("descriotion", activityInfo.description);
			reaction.put("emoji_num", activityInfo.emoji_num);
			reactionList.add(reaction);
		}
		root.put("reaction_list", reactionList);
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
