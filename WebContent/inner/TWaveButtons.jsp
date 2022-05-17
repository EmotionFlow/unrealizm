<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .AddWaveComment > .fa-comment-dots {
        font-size: 22px;
		color: #3498db;
    }
	.UserInfoCmd .WaveMessageText {
        width: 300px;
        height: 100px;
		font-size: 12px;
    }
	.UserInfoCmd .WaveMessageInfo {
		font-size: 12px;
	}
</style>


<%if(cResults.m_cUser.m_strWaveEmojiList == null){%>
<span class="UserInfoCmd" style="padding-bottom: 0">
	<%=_TEX.T("IllustV.Wave")%> <span class="AddWaveComment" onclick="$('#WaveMessage').toggle(100)"><i class="far fa-comment-dots"></i></span>
</span>

<span id="WaveMessage" class="UserInfoCmd" style="padding-bottom: 0; display: none">
	<textarea id="WaveMessageText" class="WaveMessageText" placeholder="メッセージも添える"></textarea>
	<br><span class="WaveMessageInfo">絵文字をタップすると送信します</span>
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
			<%=_TEX.T("IllustV.Wave")%> <i class="fas fa-comment-alt"></i>
		</span>
		<span class="UserInfoCmd">
		<%for(String waveEmoji: cResults.m_cUser.m_strWaveEmojiList) {%>
		<span class="WaveButton" onclick="sendUserWave(<%=checkLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>, '<%=waveEmoji%>', this)"><%=CEmoji.parse(waveEmoji)%></span>
		<%}%>
		</span>
	<%}%>
<%}%>
