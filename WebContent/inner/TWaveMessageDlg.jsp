<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	const waveMessages = {
		<%for (UserWave wave : cResults.myWaves) {%><%if (!wave.message.isEmpty()) {%>
		'<%=wave.id%>': {
			'emojiHtml': '<%=CEmoji.parse(wave.emoji)%>',
			'messageHtml': '<%=Util.toStringHtml(wave.message).replaceAll("'", "\\\\'")%>'
		},
		<%}%><%}%>
	};

	function showWaveMessage(waveId) {
		const waveMessage = waveMessages[waveId];
		if (!waveMessage) return false;
		Swal.fire({
			html:
				'<div class="WaveMessageDlg">' +
				'<div class="WaveEmoji">' + waveMessage.emojiHtml + '</div>' +
				'<div class="WaveMessage">' + waveMessage.messageHtml + '</div>' +
				'</div>',
			showConfirmButton: true,
			showCancelButton: false,
			showCloseButton: false,
		})
	}
</script>