<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeTagC results = new MyHomeTagC();
results.getParam(request);
if(isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}

results.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin, results.m_nMode, _TEX, vResult, results.m_nViewMode, nSpMode));

	if ((nCnt == 2 || nCnt == 7) && bSmartPhone){
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
	}
}
if (nCnt < 7 && bSmartPhone){
	sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
}

%>{"end_id":<%=results.m_nEndId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
