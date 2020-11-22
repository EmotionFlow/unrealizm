<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) return;
CTweet cTweet = new CTweet();
cTweet.GetResults(checkLogin.m_nUserId);
cTweet.GetMyOpenLists();
%>
{
"result": <%=(cTweet.m_bIsTweetEnable)?1:0%>,
"user_id": <%=checkLogin.m_nUserId%>,
"twitter_user_id": <%=cTweet.m_lnTwitterUserId%>,
"list_id" : [
<%
if(cTweet.m_listOpenList!=null) {
	for(int nCnt=0; nCnt<cTweet.m_listOpenList.size(); nCnt++) {%>
"<%=CEnc.E(String.valueOf(cTweet.m_listOpenList.get(nCnt).getId()))%>"<%if(nCnt<cTweet.m_listOpenList.size()-1){%>,<%}%>
<%
	}
}
%>
],
"list_name" : [
<%
if(cTweet.m_listOpenList!=null) {
	for(int nCnt=0; nCnt<cTweet.m_listOpenList.size(); nCnt++) {%>
"<%=CEnc.E(String.valueOf(cTweet.m_listOpenList.get(nCnt).getName()))%>"<%if(nCnt<cTweet.m_listOpenList.size()-1){%>,<%}%>
<%
	}
}
%>
]
}
