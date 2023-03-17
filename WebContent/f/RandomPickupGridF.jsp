<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

RandomPickupGridC results = new RandomPickupGridC();
results.getParam(request);
if(results.m_nMode==CCnv.MODE_SP) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
boolean bRtn = results.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(content, checkLogin, results.m_nMode, _TEX, vResult, CCnv.VIEW_LIST, CCnv.SP_MODE_WVIEW));
	if(nCnt==8) {
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
	}
}
%>{
"end_id" : <%=results.m_nEndId%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
