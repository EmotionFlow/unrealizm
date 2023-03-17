<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if(!checkLogin.m_bLogin) {%>
<a class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
<%} else if(results.m_bOwner) {
	// 何も表示しない
} else if(results.m_bBlocking){%>
<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
<%} else if(results.m_bBlocked){%>
<%} else if(results.m_bFollow){%>
<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%> Selected" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
<%} else {%>
<span class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=results.m_cUser.m_nUserId%>" onclick="UpdateFollowUser(<%=checkLogin.m_nUserId%>, <%=results.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
<%}%>
