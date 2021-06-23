<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="SwitchUserList" style="display: <%=openSwUsrLst?"block":"none"%>">
	<%for (MyIllustListC.SwitchUser switchUser: cResults.switchUsers) {%>
	<div class="SwitchUserItem">
				<span class="SwitchUserThumb"
					  style="background-image:url('<%=Common.GetUrl(switchUser.user.m_strFileName)%>')"
					  onclick="switchUser(<%=switchUser.signInIt ? "-1" : switchUser.user.m_nUserId%>)"></span>
		<span class="SwitchUserNickname"
			  onclick="switchUser(<%=switchUser.signInIt ? "-1" : switchUser.user.m_nUserId%>)"><%=switchUser.user.m_strNickName%></span>
		<span class="SwitchUserStatus">
				<%if(switchUser.signInIt){%>
				<i class="fas fa-check Selected"></i>
				<%}else{%>
				<i class="far fa-trash-alt Other"
				   onclick="removeSwitchUser(<%=switchUser.user.m_nUserId%>)"></i>
				<%}%>
				</span>
	</div>
	<%}%>

	<%if(cResults.switchUsers.size()<2){%>
	<a class="SwitchUserItem" href="javascript: void(0)" onclick="addSwitchUser(<%=checkLogin.m_nUserId%>)">
		<span class="SwitchUserNickname" style="text-align: center"><%=_TEX.T("SwitchAccount.Add")%></span>
	</a>
	<%}%>
</div>
