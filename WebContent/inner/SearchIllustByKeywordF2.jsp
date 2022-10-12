<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.selectMaxGallery = 30;
cResults.getParam(request);
if (isApp) {
	checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
}
cResults.getResults(checkLogin, true);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < cResults.contentList.size(); nCnt++) {
	CContent cContent = cResults.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, cResults.viewMode, nSpMode));

	if ((nCnt == 3 || nCnt == 9 || nCnt == 15 || nCnt == 21 || nCnt == 27 || nCnt == 33) && bSmartPhone) {
		sbHtml.append("<div class=\"IllustItem\" style=\"width: 360px; height: 250px; background: none; border: none; opacity: 0\">");
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
		sbHtml.append("</div>");
	}
}

%>{"end_id":<%=cResults.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
