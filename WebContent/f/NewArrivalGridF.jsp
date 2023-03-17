<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

NewArrivalGridC results = new NewArrivalGridC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_LIST, CCnv.SP_MODE_WVIEW));
}
sbHtml.append((bSmartPhone)?Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter):Util.poipiku_336x280_pc_mid(checkLogin, g_nSafeFilter));
%>{
"end_id" : <%=results.m_nEndId%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
