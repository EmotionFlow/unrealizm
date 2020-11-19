<%@page import="org.codehaus.jackson.annotate.JsonProperty"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
class Data {
	@JsonProperty("datasets")
	ArrayList<Dataset> datasets = new ArrayList<>();
	@JsonProperty("labels")
	ArrayList<String> labels = new ArrayList<>();
}
class Dataset {
	@JsonProperty("data")
	ArrayList<Integer> data = new ArrayList<>();
	@JsonProperty("backgroundColor")
	ArrayList<String> backgroundColor = new ArrayList<>();
}
class DataList {
	@JsonProperty("description")
	String description = "";
	@JsonProperty("emoji_num")
	int emoji_num = 0;
}
%>
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

	// JSONデータ作成
	if (result == ActivityAnalyzeC.OK) {
		// root
		root.put("user_id", checkLogin.m_nUserId);

		// dataの内容作成
		Data data = new Data();
		// data.labels
		for(ActivityAnalyzeC.ActivityInfo activityInfo : activityAnalyzeC.activityInfos) {
			data.labels.add(CEmoji.parseToUrl(activityInfo.description));
		}
		// data.datasets
		Dataset dataset = new Dataset();
		data.datasets.add(dataset);
		// data.datasets.data
		for(ActivityAnalyzeC.ActivityInfo activityInfo : activityAnalyzeC.activityInfos) {
			dataset.data.add((int)(Math.ceil(activityInfo.emoji_num*100.0/activityAnalyzeC.emojiNumTotal)));
		}
		// data.datasets.backgroundColor
		for(int color=0x3498dbff, i=0; i<activityAnalyzeC.activityInfos.size(); color-=20, i++) {
			dataset.backgroundColor.add(String.format("#%x", color));
		}
		root.put("data", data);

		// 一覧のhtml作成
		double otherRate = 100.0;
		ArrayList<DataList> dataLists = new ArrayList<>();
		for(ActivityAnalyzeC.ActivityInfo activityInfo : activityAnalyzeC.activityLists) {
			DataList dataList = new DataList();
			dataList.description = CEmoji.parse(activityInfo.description);
			dataList.emoji_num = (int)(Math.ceil(activityInfo.emoji_num*100.0/activityAnalyzeC.emojiNumTotal));
			dataLists.add(dataList);
			otherRate -= activityInfo.emoji_num*100.0/activityAnalyzeC.emojiNumTotal;
		}
		DataList dataList = new DataList();
		dataList.description = _TEX.T("ActivityAnalyze.List.Others");
		dataList.emoji_num = (int)Math.ceil(otherRate);
		dataLists.add(dataList);
		root.put("list", dataLists);
	}

	// JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch(JsonGenerationException e)  {
		e.printStackTrace();
} finally {
	root = null;
	mapper = null;
}
%>
