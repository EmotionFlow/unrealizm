<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyBookmarkGridC cResults = new MyBookmarkGridC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, true);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
StringBuilder sbHtml = new StringBuilder();
for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult));
	if(nCnt==8) {
		sbHtml.append((bSmartPhone)?Util.poipiku_336x280_sp_mid():Util.poipiku_336x280_pc_mid());
	}
}
%>{
"end_id" : <%=cResults.m_vContentList.size()%>,
"html" : "<%=CEnc.E(sbHtml.toString())%>"
}
