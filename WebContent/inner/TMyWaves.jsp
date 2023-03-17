<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	boolean showMoreWaves = Util.isSmartPhone(request) && results.myWaves.size() > 20;
	int showMoreEndIdx;
	if (results.myWaves.size() % 10 == 0) {
		showMoreEndIdx = results.myWaves.size() - 20 - 1;
	} else {
		showMoreEndIdx = results.myWaves.size() - (results.myWaves.size() % 10 + 10) - 1;
	}

	for (int i=0; i<results.myWaves.size(); i++) {
		UserWave wave = results.myWaves.get(i);
		if (i == 0 && showMoreWaves) {%>
		<div class="ShowMoreWaves" onclick="$('#MoreWaves').show()"><i class="fas fa-angle-double-up"></i></div>
		<div id="MoreWaves" style="display: none;">
		<%}%>
		<%if(wave.message.isEmpty()){%>
			<span class="WaveEmoji"><%=CEmoji.parse(wave.emoji)%></span>
		<%}else{%>
			<span class="WaveEmoji WithMessage" onclick="showWaveMessage(<%=wave.id%>)"><%=CEmoji.parse(wave.emoji)%><i class="fas fa-comment-dots"></i></span>
		<%}%>
		<%if(showMoreWaves && i==showMoreEndIdx){%></div><%}%>
<%}%>
