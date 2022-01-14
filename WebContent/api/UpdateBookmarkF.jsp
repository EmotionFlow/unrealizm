<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
UpdateBookmarkC cResults = new UpdateBookmarkC();
cResults.getParam(request);
int result = cResults.getResults(checkLogin);
String msg = "";
switch(result) {
case UpdateBookmarkC.BOOKMARK_BOOKMARKING:
	msg = _TEX.T("Bookmark.Added");
	break;
case UpdateBookmarkC.BOOKMARK_NONE:
	msg = _TEX.T("Bookmark.Deleted");
	break;
case UpdateBookmarkC.BOOKMARK_LIMIT:
	msg = String.format(_TEX.T("Bookmark.Limit"), Common.BOOKMARK_NUM[checkLogin.m_nPassportId]);
	break;
case UpdateBookmarkC.USER_INVALID:
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