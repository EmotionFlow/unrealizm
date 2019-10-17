<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
if(cResults.m_nMode==CCnv.MODE_SP) {
	cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
boolean bRtn = cResults.getResults(cCheckLogin, true);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, cResults.m_nMode, _TEX, vResult, cResults.m_nViewMode));
	if(nCnt==5 && bSmartPhone) {
		//sbHtml.append(Util.poipiku_320x250_sp_mid());
		sbHtml.append(Util.jikoku_hyou(request));
	}
}
%>{
"end_id" : <%=cResults.m_nEndId%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
