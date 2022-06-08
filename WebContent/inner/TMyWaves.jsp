<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	boolean showMoreWaves = Util.isSmartPhone(request) && cResults.myWaves.size() > 20;
	int showMoreEndIdx;
	if (cResults.myWaves.size() % 10 == 0) {
		showMoreEndIdx = cResults.myWaves.size() - 20 - 1;
	} else {
		showMoreEndIdx = cResults.myWaves.size() - (cResults.myWaves.size() % 10 + 10) - 1;
	}

	for (int i=0; i<cResults.myWaves.size(); i++) {
		UserWave wave = cResults.myWaves.get(i);
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
