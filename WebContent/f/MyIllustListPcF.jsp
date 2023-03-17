<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

IllustListGridC results = new IllustListGridC();
results.getParam(request);
if(results.m_nUserId==-1) {
	results.m_nUserId = checkLogin.m_nUserId;
}

results.m_bDispUnPublished = true;

if(!results.getResults(checkLogin, true)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}

ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
	CContent content = results.contentList.get(nCnt);%>
	<%=CCnv.toThumbHtml(content, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
<%}%>
