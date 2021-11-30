<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
boolean bSmartPhone = Util.isSmartPhone(request);

NewArrivalC cResults = new NewArrivalC();
cResults.selectMaxGallery = 30;
cResults.getParam(request);
cResults.getResults(checkLogin);

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);

StringBuilder sbHtml = new StringBuilder();
int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;

int nCnt;
for (nCnt = 0; nCnt < cResults.contentList.size(); nCnt++) {
	CContent cContent = cResults.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html(cContent, checkLogin.m_nUserId, cResults.mode, _TEX, vResult, cResults.viewMode, nSpMode));

	if ((nCnt == 2 || nCnt == 7 || nCnt == 12 || nCnt == 17 || nCnt == 22 || nCnt == 27) && bSmartPhone){
		sbHtml.append(Util.poipiku_336x280_sp_mid(checkLogin));
	}
}
%>{"end_id":<%=cResults.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
