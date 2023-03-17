<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
int nRtn = 0;
String strHtml = _TEX.T("Common.NeedLogin");
CheckLogin checkLogin = new CheckLogin(request, response);
if(checkLogin.m_bLogin) {
	ShowAllReactionC results = new ShowAllReactionC();
	results.getParam(request);
	results.getResults();
	StringBuilder strRtn = new StringBuilder();

	CCnv.appendResEmoji(strRtn, results.contentUserId,
			results.comments, results.lastCommentId, checkLogin.m_nUserId, false);

	strHtml = strRtn.toString();
	nRtn = 1;
}
%>{
"result_num" : <%=nRtn%>,
"html" : "<%=CEnc.E(strHtml)%>"
}