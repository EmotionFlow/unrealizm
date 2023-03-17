<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
if(Util.isBot(request)) {
	return;
}
final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm.com")) {
	Log.d("不正アクセス(referer不一致):" + referer);
	//return;
}

CheckLogin checkLogin = new CheckLogin(request, response);

SearchUserByKeywordC results = new SearchUserByKeywordC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);

for(int nCnt = 0; nCnt<results.selectByNicknameUsers.size(); nCnt++) {
	CUser cUser = results.selectByNicknameUsers.get(nCnt);%>
	<%=CCnv.toHtmlUser(cUser)%>
<%}%>
