<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page import="jp.pipa.poipiku.cache.CacheUsers0000.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
int userId = UserAuthUtil.updatePassword(request, response);
User user = CacheUsers0000.getInstance().getUser(userId);
String poipikuLk = "";
if(user!=null) {
	poipikuLk = user.hashPass;
}

Map<String, Object> jsonMap = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	jsonMap = new HashMap<String, Object>();
	jsonMap.put("result", userId);
	jsonMap.put(Common.AI_POIPIKU_LK, poipikuLk);

	//JSONに変換して出力
	mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(jsonMap);
	out.print(json);
	//Log.d(json);
} catch(JsonGenerationException e) {
	e.printStackTrace();
} finally {
	jsonMap = null;
	mapper = null;
}
%>
