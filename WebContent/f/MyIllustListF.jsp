<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;

IllustListC results = new IllustListC();
results.getParam(request);
if(results.m_nUserId==-1) {
	results.m_nUserId = checkLogin.m_nUserId;
}else if(results.m_nUserId==checkLogin.m_nUserId){
	results.m_bDispUnPublished = true;
}

boolean bRtn = results.getResults(checkLogin, true);
%>
<%if(results.contentList.size()>0) {%>
	<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
		CContent content = results.contentList.get(nCnt);%>
		<%=CCnv.toThumbHtml(content, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
	<%}%>
<%}%>
