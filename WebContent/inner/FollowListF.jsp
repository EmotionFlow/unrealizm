<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

FollowListC cResults = new FollowListC();
cResults.getParam(request);
cResults.m_nMode = followMode;

cResults.getResults(checkLogin, true);

StringBuilder sbHtml = new StringBuilder();
for(int nCnt = 0; nCnt<cResults.userList.size(); nCnt++) {
	CUser cUser = cResults.userList.get(nCnt);
	if (Util.isSmartPhone(request)) {
		if (isApp) {
	sbHtml.append(CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP));
		} else {
			sbHtml.append(CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW));
		}
	} else {
		sbHtml.append(CCnv.toHtmlUser(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW));
	}
}

%>
{"end_id":<%=cResults.endId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
