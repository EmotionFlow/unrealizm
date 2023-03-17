<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	final String shareMessage =
			String.format("%s%s %s #%s",
					results.m_cUser.m_strNickName,
					_TEX.T("Twitter.UserAddition"),
					String.format(_TEX.T("Twitter.UserPostNum"), results.m_nContentsNumTotal),
					_TEX.T("Common.HashTag")).replace("\"", "\\\"");
	final String shareUri = (
			"https://unrealizm.com/" + results.m_cUser.m_nUserId + "/").replace("\"", "\\\"");;
%>
<script>
	function DispSharedMsg() {
		DispMsg("<%=_TEX.T("Share.Done")%>");
	}
</script>
<span id="UserShareCmd" class="NonFrameBtnBase" >
	<img class="UserShareButton" src="/img/share_sp.svg" onclick='shareUser(<%=results.m_cUser.m_nUserId%>, "<%=shareMessage%>", "<%=shareUri%>", true);' alt="share">
</span>
