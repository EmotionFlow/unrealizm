<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% for (MyIllustListC.ReplyWave reply: cResults.replyWaves) { %>
<span class="WaveEmoji WithMessage" onclick="showReplyWaveMessage(<%=reply.wave.id%>)">
	<%=CEmoji.parse(reply.wave.emoji)%>
	<i class="fas fa-comment-dots"></i>
</span>
<%}%>
