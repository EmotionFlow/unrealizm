<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

NewArrivalC cResults = new NewArrivalC();
cResults.selectMaxGallery = 16;
cResults.getParam(request);
cResults.getResults(checkLogin);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < cResults.contentList.size(); nCnt++) {
	CContent cContent = cResults.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, cResults.viewMode, nSpMode));

	if (false){
//		if ((nCnt == 2 || nCnt == 7 || nCnt == 12 || nCnt == 17 || nCnt == 22 || nCnt == 27) && bSmartPhone){
		sbHtml.append("<div class=\"IllustItem\" style=\"width: 360px; height: 250px; background: none; border: none; opacity: 0\">");
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
		sbHtml.append("</div>");
	}
}
%>{"end_id":<%=cResults.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
