<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	final String shareMessage =
			String.format("%s%s %s #%s",
					cResults.m_cUser.m_strNickName,
					_TEX.T("Twitter.UserAddition"),
					String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nContentsNumTotal),
					_TEX.T("Common.HashTag")).replace("\"", "\\\"");
	final String shareUri = (
			"https://poipiku.com/" + cResults.m_cUser.m_nUserId + "/").replace("\"", "\\\"");;
%>
<span id="UserShareCmd" class="NonFrameBtnBase" >
	<img class="UserShareButton" src="/img/share_sp.svg" onclick='shareUser("<%=shareMessage%>", "<%=shareUri%>", <%=bSmartPhone%>);' alt="share">
</span>
