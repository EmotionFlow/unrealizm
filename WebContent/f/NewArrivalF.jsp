<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if (g_isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

NewArrivalC results = new NewArrivalC();
results.selectMaxGallery = 16;
results.getParam(request);
results.getResults(checkLogin);

StringBuilder sbHtml = new StringBuilder();

int nCnt;
for (nCnt = 0; nCnt < results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);
	sbHtml.append(CCnv.Content2Html2Column(content, checkLogin, _TEX));
}
%>{"end_id":<%=results.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
