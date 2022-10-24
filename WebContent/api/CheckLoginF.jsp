<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
Map<String, Object> user = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	user = new HashMap<String, Object>();
	user.put("user_id", checkLogin.m_nUserId);
	user.put(Common.UNREALIZM_LK, checkLogin.m_strHashPass);
	user.put("premium_id", checkLogin.m_nPassportId);
	user.put("passport_id", checkLogin.m_nPassportId);
	user.put("lang_id", checkLogin.m_nPassportId);
	user.put("DESC_MAX_UPLOAD", Common.EDITOR_DESC_MAX[0][checkLogin.m_nPassportId]);
	user.put("DESC_MAX_PASETE", Common.EDITOR_DESC_MAX[0][checkLogin.m_nPassportId]);
	user.put("DESC_MAX_BASIC_PAINT", Common.EDITOR_DESC_MAX[0][checkLogin.m_nPassportId]);
	user.put("DESC_MAX_TEXT", Common.EDITOR_DESC_MAX[0][checkLogin.m_nPassportId]);
	user.put("TEXT_MAX_UPLOAD", Common.EDITOR_TEXT_MAX[0][checkLogin.m_nPassportId]);
	user.put("TEXT_MAX_PASETE", Common.EDITOR_TEXT_MAX[0][checkLogin.m_nPassportId]);
	user.put("TEXT_MAX_BASIC_PAINT", Common.EDITOR_TEXT_MAX[0][checkLogin.m_nPassportId]);
	user.put("TEXT_MAX_TEXT", Common.EDITOR_TEXT_MAX[0][checkLogin.m_nPassportId]);
	user.put("UPLOAD_FILE_MAX", Common.UPLOAD_FILE_MAX[checkLogin.m_nPassportId]);
	user.put("UPLOAD_FILE_TOTAL_SIZE", Common.UPLOAD_FILE_TOTAL_SIZE[checkLogin.m_nPassportId]);

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