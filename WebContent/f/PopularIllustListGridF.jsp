<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

PopularIllustListGridC cResults = new PopularIllustListGridC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult));
	if(nCnt==8) {
		sbHtml.append((bSmartPhone)?Util.poipiku_336x280_sp_mid(checkLogin):Util.poipiku_336x280_pc_mid(checkLogin));
	}
}
%>{
"end_id" : <%=cResults.m_vContentList.size()%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
