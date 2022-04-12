<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page import="java.util.*"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int result = UpdateGenreFileC.ERR_UNKNOWN;
UpdateGenreInfoC results = new UpdateGenreInfoC();
result = results.getParam(request);
//Log.d("userId:"+results.userId);
//Log.d("genreId:"+results.genreId);
//Log.d("type:"+results.type);
//Log.d("data:"+results.data);
if(result==UpdateGenreFileC.OK_PARAM) {
	result = results.getResults(checkLogin, getServletContext());
}

String strMessage = "";
switch(result) {
case UpdateGenreInfoC.OK_EDIT:
	strMessage = _TEX.T("Common.Saved");
	break;
case UpdateGenreInfoC.ERR_NOT_LOGIN:
	strMessage = _TEX.T("Common.Error.ERR_NOT_LOGIN");
	break;
case UpdateGenreInfoC.ERR_TEXT_SIZE_MAX:
	strMessage = _TEX.T("Common.Error.ERR_TEXT_SIZE_MAX");
	break;
case UpdateGenreInfoC.ERR_TEXT_SIZE_MIN:
	strMessage = _TEX.T("Common.Error.ERR_TEXT_SIZE_MIN");
	break;
case UpdateGenreInfoC.ERR_NOT_PASSPORT:
	strMessage = _TEX.T("Common.Error.ERR_NOT_PASSPORT");
	break;
case UpdateGenreInfoC.ERR_NEED_GENRE_NAME:
	strMessage = _TEX.T("Common.Error.ERR_NEED_GENRE_NAME");
	break;
case UpdateGenreInfoC.ERR_SAME_GENRE_NAME:
	strMessage = _TEX.T("Common.Error.ERR_SAME_GENRE_NAME");
	break;
case UpdateGenreInfoC.ERR_UNKNOWN:
default:
	strMessage = _TEX.T("Common.Error.ERR_UNKNOWN");
	break;
}

//JSON元データを格納する連想配列
Map<String, Object> root = null;
ObjectMapper mapper = null;

try {
	//ユーザの情報
	root = new HashMap<String, Object>();
	root.put("result", result);
	root.put("genre_id", results.genreId);
	root.put("message", strMessage);

	//JSONに変換して出力
	mapper = new ObjectMapper();
	out.print(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(root));
} catch (JsonGenerationException e) {
	e.printStackTrace();
} finally {
	root = null;
	mapper = null;
}
%>