<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if (isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

NewArrivalC results = new NewArrivalC();
results.selectMaxGallery = 16;
results.getParam(request);
results.getResults(checkLogin);

ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent cContent = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, results.viewMode, nSpMode));
}
%>{"end_id":<%=results.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
