<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page import="java.util.stream.Collectors" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%!
	static class JsonPin {
		public int order;
		public int content_id;
		JsonPin(int _order, int _content_id) {
			order = _order;
			content_id = _content_id;
		}
	}
%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) return;

GetPinListC results = new GetPinListC();
results.getParam(request);

boolean result = results.getResults(checkLogin);

List<JsonPin> jsonPins = results.pins.stream()
		.map( e -> new JsonPin(e.dispOrder, e.contentId))
		.collect(Collectors.toList());

//JSONデータ作成
Map<String, Object> root = null;
ObjectMapper mapper = null;
try {
	root = new HashMap<String, Object>();
	root.put("result", result?Common.API_OK:Common.API_NG);
	root.put("confirm_msg", _TEX.T("Pin.Confirm"));
	root.put("pins", jsonPins);
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
