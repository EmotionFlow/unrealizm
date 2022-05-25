<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% for (UserWave wave: cResults.myWaves) { %>
<%if(wave.message.isEmpty()){%>
<span class="WaveEmoji">
<%=CEmoji.parse(wave.emoji)%>
</span>
<%}else{%>
<span class="WaveEmoji" onclick="showWaveMessage(<%=wave.id%>)">
	<%=CEmoji.parse(wave.emoji)%>
	<i class="fas fa-comment-dots"></i>
</span>
<%}%>
<%}%>
