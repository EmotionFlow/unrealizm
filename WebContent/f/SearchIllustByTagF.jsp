<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if (g_isApp) checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

SearchIllustByTagC results = new SearchIllustByTagC();
results.selectMaxGallery = 30;
results.getParam(request);
results.getResults(checkLogin, true);

StringBuilder sbHtml = new StringBuilder();
for (CContent content : results.contentList) {
	sbHtml.append(CCnv.Content2Html2Column(content, checkLogin, _TEX));
}
%>{"end_id":<%=results.lastContentId%>,"html":"<%=CEnc.E(sbHtml.toString())%>"}
