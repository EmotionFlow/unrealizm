<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

MySketchbookC cResults = new MySketchbookC();
cResults.selectMaxGallery = 30;
cResults.getParam(request);
cResults.getResults(checkLogin);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < cResults.contentList.size(); nCnt++) {
	CContent cContent = cResults.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin.m_nUserId, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, cResults.viewMode, nSpMode));

	if ((nCnt == 2 || nCnt == 7 || nCnt == 12 || nCnt == 17 || nCnt == 22 || nCnt == 27) && bSmartPhone){
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
	}
}
%>{"end_id":<%=cResults.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}