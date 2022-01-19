<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
UpdatePinC cResults = new UpdatePinC();
cResults.getParam(request);
int result = cResults.getResults(checkLogin);
String msg = "";
switch(result) {
	case UpdatePinC.PIN_ADDED:
		msg = "この作品をピン留めしました。ピン留め作品は常に作品リストの最初に表示されます。";
		break;
	case UpdatePinC.PIN_UPDATED:
		msg = "ピン留め作品を変更しました";
		break;
	case UpdatePinC.PIN_REMOVED:
		msg = "作品のピン留めを外しました";
		break;
	case UpdatePinC.USER_INVALID:
		msg = _TEX.T("Common.NeedLogin");
		break;
}

//JSONデータ作成
Map<String, Object> root = null;
ObjectMapper mapper = null;
try {
	root = new HashMap<String, Object>();
	root.put("result", result);
	root.put("msg", msg);
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