<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

UpdateActivityListC cResults = new UpdateActivityListC();
cResults.getParam(request);
int rtn = cResults.getResults(checkLogin);

Map<String, Object> user = null;
ObjectMapper mapper = null;
try {
	//ユーザの情報
	user = new HashMap<String, Object>();
	user.put("result", rtn);
	//JSONに変換して出力
	mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(user);
	out.print(json);
	//Log.d(json);
} catch(JsonGenerationException e) {
	e.printStackTrace();
} finally {
	user = null;
	mapper = null;
}
%>
