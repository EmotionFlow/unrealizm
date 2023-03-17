<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) return;

UpdatePinC results = new UpdatePinC();
results.getParam(request);
int result = results.getResults(checkLogin);
String msg = "";
switch(result) {
	case UpdatePinC.PIN_ADDED:
		msg = _TEX.T("Pin.Added");
		break;
	case UpdatePinC.PIN_UPDATED:
		msg = _TEX.T("Pin.Updated");
		break;
	case UpdatePinC.PIN_REMOVED:
		msg = _TEX.T("Pin.Removed");
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