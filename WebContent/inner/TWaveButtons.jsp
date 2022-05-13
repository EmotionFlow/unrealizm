<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%if(cResults.m_cUser.m_strWaveEmojiList == null){%>
<span class="UserInfoCmd" style="padding-bottom: 0">
	<%=_TEX.T("IllustV.Wave")%>
</span>
<span class="UserInfoCmd">
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[0]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[0])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[1]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[1])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[2]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[2])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[3]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[3])%></span>
</span>
<%}else{%>
	<%if(!(!cResults.m_cUser.m_strWaveEmojiList.isEmpty() && cResults.m_cUser.m_strWaveEmojiList.get(0).equals(UserWaveTemplate.DISABLE_WAVE_CHAR))){%>
		<span class="UserInfoCmd" style="padding-bottom: 0">
			<%=_TEX.T("IllustV.Wave")%>
		</span>
		<span class="UserInfoCmd">
		<%for(String waveEmoji: cResults.m_cUser.m_strWaveEmojiList) {%>
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=waveEmoji%>', this)"><%=CEmoji.parse(waveEmoji)%></span>
		<%}%>
		</span>
	<%}%>
<%}%>
