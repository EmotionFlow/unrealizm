<%@ page import="org.codehaus.jackson.map.ObjectMapper" %>
<%@ page import="org.codehaus.jackson.JsonGenerationException" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) return;

boolean result = false;
int error_code;
String text = "";

int requestId = Util.toInt(request.getParameter("ID"));

Request poipikuRequest = null;
if (requestId>0) {
	poipikuRequest = new Request(requestId);
	result = poipikuRequest.id > 0;
	text = poipikuRequest.requestText;
	error_code = poipikuRequest.errorKind.getCode();
} else {
	error_code = Controller.ErrorKind.Unknown.getCode();
}

Map<String, Object> root;
ObjectMapper mapper;
try {
	root = new HashMap<>();
	root.put("result", result);
	root.put("error_code", error_code);
	root.put("text", text);
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch(JsonGenerationException e)  {
	e.printStackTrace();
}
%>
