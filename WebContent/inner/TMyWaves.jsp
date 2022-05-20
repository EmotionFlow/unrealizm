<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% for (UserWave wave: cResults.myWaves) { %>
<%if(wave.message.isEmpty()){%>
<%=CEmoji.parse(wave.emoji)%>
<%}else{%>
<span class="WaveWithComment" onclick="showWaveMessage(<%=wave.id%>)">
						<%=CEmoji.parse(wave.emoji)%>
						<i class="fas fa-comment-dots"></i>
					</span>
<%}%>
<%}%>
