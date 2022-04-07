<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);

if (cResults.page != 1) {
	cResults.getResults(checkLogin, false, false);
} else {
	cResults.getResults(checkLogin, true, true);
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nCnt;
for (nCnt = 0; nCnt < cResults.contentList.size(); nCnt++) {
	CContent cContent = cResults.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin, cResults.mode, _TEX, vResult, cResults.viewMode, CCnv.SP_MODE_WVIEW));

	if (cResults.page == 1) {
		if (nCnt == 2) {
			sbHtml.append("<h2 class=\"IllustItemListRecommendedTitle\">").append(_TEX.T("MyHome.Recommended.Users")).append("</h2>");
			for (CUser recommendedUser : cResults.recommendedUserList) {
				sbHtml.append(CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_WVIEW));
			}
		} else if (nCnt == 5 && bSmartPhone){
			sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
		} else if (nCnt == 6) {
			sbHtml.append("<h2 class=\"IllustItemListRecommendedTitle\">").append(_TEX.T("MyHome.Recommended.RequestCreators")).append("</h2>");
			for (CUser recommendedUser: cResults.recommendedRequestCreatorList) {
				sbHtml.append(CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_WVIEW));
			}
		}
	} else {
		if ((nCnt == 2 || nCnt == 7) && bSmartPhone){
			sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
		}
	}
}
if (nCnt < 7 && bSmartPhone){
	sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
}

%>{"end_id":<%=cResults.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
