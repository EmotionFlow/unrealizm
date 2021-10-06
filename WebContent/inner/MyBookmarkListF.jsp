<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyBookmarkC cResults = new MyBookmarkC();
cResults.getParam(request);

if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
cResults.selectMaxGallery = 18;
cResults.getResults(checkLogin, true);

int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

StringBuilder sbHtml = new StringBuilder();
for (int nCnt = 0; nCnt < cResults.m_vContentList.size(); nCnt++) {
	CContent cContent = cResults.m_vContentList.get(nCnt);
	sbHtml.append(CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX));
	if(nCnt==8) {
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin));
	}
}

%>{"end_id":<%=cResults.m_nEndId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}

