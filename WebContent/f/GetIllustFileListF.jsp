<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if (!checkLogin.m_bLogin) {
	return;
}

GetIllustFileListC results = new GetIllustFileListC();
results.getParam(request);

int nRtn = results.getResults(checkLogin);

if (nRtn > 0) {
	response.setHeader("Access-Control-Allow-Origin", "https://ai-img.poipiku.com");

	//オブジェクト配列をJSONに変換
	ObjectMapper mapper = null;
	try {
		mapper = new ObjectMapper();
		out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(results.contentList));
	} catch(JsonGenerationException e) {
		e.printStackTrace();
	}
}
%>
