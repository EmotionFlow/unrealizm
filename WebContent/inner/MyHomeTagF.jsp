<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyHomeTagC results = new MyHomeTagC();
results.getParam(request);
if(g_isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}

results.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nSpMode = g_isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(content, checkLogin, results.m_nMode, _TEX, vResult, results.m_nViewMode, nSpMode));
}
%>{"end_id":<%=results.m_nEndId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
