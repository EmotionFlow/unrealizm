<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="IllustBrowserVGiftButton.jsp"%>
<%@ include file="IllustVBlockButton.jsp"%>
<div class="UserInfoBg"></div>
<section class="UserInfoUser">
	<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>')" href="/<%=cResults.m_cUser.m_nUserId%>/"></a>
	<h2 class="UserInfoUserName"><a href="/<%=cResults.m_cUser.m_nUserId%>/"><%=cResults.m_cUser.m_strNickName%></a></h2>

	<%if(cResults.twitterScreenName != null && !cResults.twitterScreenName.isEmpty()) {%>
	<h3 class="UserInfoProfile"><a class="fab fa-twitter" href="https://twitter.com/<%=cResults.twitterScreenName%>">@<%=cResults.twitterScreenName%></a></h3>
	<%}%>

	<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
	<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
	<%}%>

	<span class="UserInfoCmd">
		<%@ include file="TFollowButton.jsp"%>
		<%@ include file="IllustBrowserVRequestButton.jsp"%>
		<%@ include file="TUserShareCmd.jsp"%>
	</span>
	<span class="UserInfoCmd" style="padding-bottom: 0">
		絵文字で応援！
	</span>
	<span class="UserInfoCmd">
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[0]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[0])%></span>
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[1]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[1])%></span>
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[2]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[2])%></span>
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[3]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[3])%></span>
	</span>
</section>
<section class="UserInfoState">
	<%@include file="IllustBrowserVUserInfoState.jsp"%>
</section>
