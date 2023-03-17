<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeC results = new MyHomeC();
results.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

boolean bRtn = results.getResults(checkLogin);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt = 0; nCnt<results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin, results.mode, _TEX, vResult, results.viewMode, CCnv.SP_MODE_APP));
	if(nCnt==5 && bSmartPhone) {
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
	}
}
%>{
"end_id" : <%=results.lastContentId%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
