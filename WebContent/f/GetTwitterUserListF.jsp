<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
if(!cCheckLogin.m_bLogin) return;
CTweet cTweet = new CTweet();
cTweet.GetResults(cCheckLogin.m_nUserId);
cTweet.getList(cCheckLogin.m_nUserId);
%>
{
"result": <%=(cTweet.m_bIsTweetEnable)?1:0%>,
"user_id": <%=cCheckLogin.m_nUserId%>,
"twitter_user_id": <%=cTweet.m_lnTwitterUserId%>,
"list_id" : [
<%
if(cTweet.m_listUserList!=null) {
	for(int nCnt=0; nCnt<cTweet.m_listUserList.size(); nCnt++) {%>
"<%=CEnc.E(String.valueOf(cTweet.m_listUserList.get(nCnt).getId()))%>"<%if(nCnt<cTweet.m_listUserList.size()-1){%>,<%}%>
<%
	}
}
%>
],
"list_name" : [
<%
if(cTweet.m_listUserList!=null) {
	for(int nCnt=0; nCnt<cTweet.m_listUserList.size(); nCnt++) {%>
"<%=CEnc.E(String.valueOf(cTweet.m_listUserList.get(nCnt).getName()))%>"<%if(nCnt<cTweet.m_listUserList.size()-1){%>,<%}%>
<%
	}
}
%>
]
}
