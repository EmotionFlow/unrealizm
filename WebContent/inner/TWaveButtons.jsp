<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%if(cResults.m_cUser.isWaveEnable){%>
<span class="UserInfoCmd" style="padding-bottom: 0">
	<%=_TEX.T("IllustV.Wave")%>
	<%if(cResults.m_cUser.isWaveCommentEnable){%>
	<span title="send message" class="AddWaveMessage" onclick="$('#WaveMessage').toggle(100)"><i class="far fa-comment-dots"></i></span>
	<%}%>
</span>

<%if(cResults.m_cUser.isWaveCommentEnable){%>
<span class="UserInfoCmd" style="padding-bottom: 0">
<span id="WaveMessage" class="UserInfoCmd" style="padding-bottom: 0; display: none">
	<textarea maxlength="500" id="EditWaveMessage" class="WaveMessageText" placeholder="<%=_TEX.T("TWaveButtons.EditWaveMessage")%>"></textarea>
	<br><span class="WaveMessageInfo"><%=_TEX.T("TWaveButtons.WaveMessageInfo")%></span>
</span></span>
<%}%>

<span class="UserInfoCmd">
<%if(cResults.m_cUser.m_strWaveEmojiList == null){%>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[0]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[0])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[1]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[1])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[2]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[2])%></span>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=Emoji.USER_WAVE_EMOJI_DEFAULT[3]%>', this)"><%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[3])%></span>
<%}else{%>
<%for(String waveEmoji: cResults.m_cUser.m_strWaveEmojiList) {%>
<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=waveEmoji%>', this)"><%=CEmoji.parse(waveEmoji)%></span>
<%}%>
</span>
<%}%>
<%}%>
