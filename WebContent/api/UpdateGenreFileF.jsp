<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

int nRtn = UpdateGenreFileC.ERR_UNKNOWN;
UpdateGenreFileC cResults = new UpdateGenreFileC();
nRtn = cResults.getParam(request);
if(nRtn==UpdateGenreFileC.OK_PARAM) {
	nRtn = cResults.getResults(checkLogin, getServletContext());
}

String strMessage = "";
switch(nRtn) {
case UpdateGenreFileC.OK_EDIT:
	strMessage = _TEX.T("Common.Saved");
	break;
case UpdateGenreFileC.ERR_NOT_LOGIN:
	strMessage = _TEX.T("Common.Error.ERR_NOT_LOGIN");
	break;
case UpdateGenreFileC.ERR_FILE_SIZE:
	strMessage = _TEX.T("Common.Error.ERR_FILE_SIZE");
	break;
case UpdateGenreFileC.ERR_NOT_PASSPORT:
	strMessage = _TEX.T("Common.Error.ERR_NOT_PASSPORT");
	break;
case UpdateGenreFileC.ERR_UNKNOWN:
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
	root.put("result", nRtn);
	root.put("genre_id", cResults.genreId);
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