<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeTagC cResults = new MyHomeTagC();
cResults.getParam(request);
if(isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}

cResults.getResults(checkLogin, true);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

for (int nCnt = 0; nCnt < cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin.m_nUserId, cResults.m_nMode, _TEX, vResult, cResults.m_nViewMode, nSpMode));

	if (nCnt == 5 && bSmartPhone) {
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin));
	}
}
%>{"end_id":<%=cResults.m_nEndId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
