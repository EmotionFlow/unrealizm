<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

MyBookmarkC results = new MyBookmarkC();
results.getParam(request);

if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
results.selectMaxGallery = 18;
results.getResults(checkLogin, true);

int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

StringBuilder sbHtml = new StringBuilder();
for (int nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX));
	if(nCnt==8) {
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
	}
}

%>{"end_id":<%=results.endId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}

