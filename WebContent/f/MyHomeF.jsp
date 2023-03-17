<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

MyHomeC results = new MyHomeC();
results.getParam(request);

if (results.page != 1) {
	results.getResults(checkLogin, false, false);
} else {
	results.getResults(checkLogin, false, true);
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nCnt;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin, results.mode, _TEX, vResult, results.viewMode, CCnv.SP_MODE_WVIEW));

	if (results.page == 1) {
		if (nCnt == 2 && results.recommendedUserList != null && !results.recommendedUserList.isEmpty()) {
			sbHtml.append("<h2 class=\"IllustItemListRecommendedTitle\">").append(_TEX.T("MyHome.Recommended.Users")).append("</h2>");
			for (CUser recommendedUser : results.recommendedUserList) {
				sbHtml.append(CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_WVIEW));
			}
		} else if (nCnt == 5 && bSmartPhone){
			sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin, g_nSafeFilter));
		} else if (nCnt == 6 && results.recommendedRequestCreatorList != null && !results.recommendedRequestCreatorList.isEmpty() ) {
			sbHtml.append("<h2 class=\"IllustItemListRecommendedTitle\">").append(_TEX.T("MyHome.Recommended.RequestCreators")).append("</h2>");
			for (CUser recommendedUser: results.recommendedRequestCreatorList) {
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

%>{"end_id":<%=results.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
