<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<a class="UserInfoStateItem" href="/<%=cResults.m_cUser.m_nUserId%>/">
	<%if(!cResults.m_bBlocked) {%>
	<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
	<span class="UserInfoStateItemNum"><%=cResults.m_nContentsNumTotal%></span>
	<%}%>
</a>
<a class="UserInfoStateItem" href="/FollowListAppV.jsp">
	<%if(!cResults.m_bBlocked) {%>
	<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
	<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
	<%}%>
</a>
<a class="UserInfoStateItem" href="/FollowerListAppV.jsp">
	<%if(!cResults.m_bBlocked) {%>
	<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follower")%></span>
	<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowerNum%></span>
	<%}%>
</a>
