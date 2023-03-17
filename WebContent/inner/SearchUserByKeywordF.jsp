<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
if(Util.isBot(request)) {
	return;
}

final String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm.com")) {
	Log.d("不正アクセス(referer不一致):" + referer);
	return;
}


CheckLogin checkLogin = new CheckLogin(request, response);

SearchUserByKeywordC results = new SearchUserByKeywordC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

for(int nCnt = 0; nCnt<results.selectByNicknameUsers.size(); nCnt++) {
	CUser cUser = results.selectByNicknameUsers.get(nCnt);%>
	<%=CCnv.toHtmlUser(cUser, CCnv.MODE_SP, _TEX, nSpMode)%>
	<%if((nCnt+1)%9==0) {%>
	<%@ include file="/inner/TAd336x280_mid.jsp"%>
	<%}
}%>
