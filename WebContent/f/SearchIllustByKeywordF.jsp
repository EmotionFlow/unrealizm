<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin, true);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
%>
<div id="IllustThumbList" class="IllustThumbList">
	<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
		CContent cContent = cResults.m_vContentList.get(nCnt);%>
		<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_KEYWORD_ILLUST, CCnv.MODE_SP, strEncodedKeyword, _TEX)%>
		<%if((nCnt+1)%15==0) {%>
		<%@ include file="/inner/TAdMid.jspf"%>
		<%}%>
	<%}%>
</div>
