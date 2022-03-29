<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
int nRtn = 0;
String strHtml = _TEX.T("Common.NeedLogin");
CheckLogin checkLogin = new CheckLogin(request, response);
if(checkLogin.m_bLogin) {
	ShowAllReactionC cResults = new ShowAllReactionC();
	cResults.getParam(request);
	cResults.getResults();
	StringBuilder strRtn = new StringBuilder();

	CCnv.appendResEmoji(strRtn, cResults.contentUserId,
			cResults.comments, cResults.lastCommentId, checkLogin.m_nUserId);

	strHtml = strRtn.toString();
	nRtn = 1;
}
%>{
"result_num" : <%=nRtn%>,
"html" : "<%=CEnc.E(strHtml)%>"
}