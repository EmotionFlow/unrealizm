<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

GetContentsByUserC results = new GetContentsByUserC();
results.selectMaxGallery = 10;
results.getParam(request);

final int pageNum = Util.toInt(request.getParameter("PG"));

boolean needRelated;
boolean needRecommended;
if (pageNum == 0) {
	needRelated = true;
	needRecommended = true;
} else {
	needRelated = false;
	needRecommended = false;
}

boolean result = results.getResults(checkLogin, needRelated, needRecommended);
if (!result) {
	Log.d("コンテンツが取得できなかった");
	return;
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
g_bShowAd = (results.owner.passportId==Common.PASSPORT_OFF || results.owner.adMode==CUser.AD_MODE_SHOW);
int nSpMode = g_isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
boolean relatedAppended = false;
boolean recommendedAppended = false;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(
			content, checkLogin, results.mode,
			_TEX, vResult, CCnv.VIEW_DETAIL, nSpMode,
			results.isOwner?CCnv.PageCategory.MY_ILLUST_LIST:CCnv.PageCategory.DEFAULT));

	if (nCnt == 0) {
		if (!results.relatedContentList.isEmpty()) {
			sbHtml.append("<h2 class=\"IllustItemListRelatedTitle\">").append(_TEX.T("IllustV.Related")).append("</h2>");
			sbHtml.append("<section class=\"IllustItemList2Column\">");
			for (CContent c: results.relatedContentList) {
				sbHtml.append(CCnv.Content2Html2Column(c, checkLogin, _TEX));
			}
			sbHtml.append("</section>");
		}
		relatedAppended = true;

	} else if (nCnt == 8) {
		if (!results.recommendedContentList.isEmpty()) {
			sbHtml.append("<h2 class=\"IllustItemListRelatedTitle\">").append(_TEX.T("IllustV.Recommended")).append("</h2>");
			sbHtml.append("<section class=\"IllustItemList2Column\">");
			for (CContent c : results.recommendedContentList) {
				sbHtml.append(CCnv.Content2Html2Column(c, checkLogin, _TEX));
			}
			sbHtml.append("</section>");
		}
		recommendedAppended = true;
	}

}

if (needRelated && !relatedAppended) {
	if (!results.relatedContentList.isEmpty()) {
		sbHtml.append("<h2 class=\"IllustItemListRelatedTitle\">").append(_TEX.T("IllustV.Related")).append("</h2>");
		sbHtml.append("<section class=\"IllustItemList2Column\">");
		for (CContent c : results.relatedContentList) {
			sbHtml.append(CCnv.Content2Html2Column(c, checkLogin, _TEX));
		}
		sbHtml.append("</section>");
	}
}
if (needRecommended && !recommendedAppended) {
	if (!results.recommendedContentList.isEmpty()) {
		sbHtml.append("<h2 class=\"IllustItemListRelatedTitle\">").append(_TEX.T("IllustV.Recommended")).append("</h2>");
		sbHtml.append("<section class=\"IllustItemList2Column\">");
		for (CContent c: results.recommendedContentList) {
			sbHtml.append(CCnv.Content2Html2Column(c, checkLogin, _TEX));
		}
		sbHtml.append("</section>");
	}
}

%>{"end_id":<%=results.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
