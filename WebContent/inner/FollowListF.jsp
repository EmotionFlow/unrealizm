<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

FollowListC results = new FollowListC();
results.getParam(request);
results.m_nMode = followMode;

results.getResults(checkLogin, true);

StringBuilder sbHtml = new StringBuilder();
for(int nCnt = 0; nCnt<results.userList.size(); nCnt++) {
	CUser cUser = results.userList.get(nCnt);
	if (g_isApp) {
		sbHtml.append(CCnv.toHtmlUserMini(cUser));
	} else {
		sbHtml.append(CCnv.toHtmlUserMini(cUser));
	}
}

%>
{"end_id":<%=results.endId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
