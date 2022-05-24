<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	const waveMessages = {
		<%for (UserWave wave : cResults.myWaves) {%><%if (!wave.message.isEmpty()) {%>
		'<%=wave.id%>': {
			'emojiHtml': '<%=CEmoji.parse(wave.emoji)%>',
			'messageHtml': '<%=Util.toStringHtml(wave.message).replaceAll("'", "\\\\'")%>',
			'reply': '',
			'replied': false,
		},
		<%}%><%}%>
	};

	function getWaveMessageDlgHtml(waveMessage) {
		let html =  `
<style>
.WaveMessageReplyTitle {
	margin-top: 10px;
	font-size: 14px;
}
#EditWaveMessageReply {
	width: 23em;
	height: 7em;
}
.swal2-popup .swal2-styled.swal2-confirm {
	font-size: 14px;
}
</style>
` + '<div class="WaveMessageDlg">' +
	'<div class="WaveEmoji">' + waveMessage.emojiHtml + '</div>' +
	'<div class="WaveMessage">' + waveMessage.messageHtml + '</div>';
		if (!waveMessage.replied) {
			html += `<div class="WaveMessageReply">
<div class="WaveMessageReplyTitle"><i class="fas fa-reply"></i> メッセージに返信する</div>
<div class="WaveMessageReplyText">
<textarea id="EditWaveMessageReply" maxlength="500" placeholder="max 500 chars">`+ waveMessage.reply +`</textarea>
</div>
</div>`;
		} else {
			html += `<div class="WaveMessageReply">
<div class="WaveMessageReplyTitle"><i class="fas fa-reply"></i> 返信済みです</div>
<div class="WaveMessageReplyText">
<textarea id="EditWaveMessageReply" readonly="readonly" disabled="disabled">`+ waveMessage.reply +`</textarea>
</div>
</div>`;
		}
		html += '</div>';
		return html;
	}

	function showWaveMessage(waveId) {
		const waveMessage = waveMessages[waveId];
		if (!waveMessage) return false;
		Swal.fire({
			html: getWaveMessageDlgHtml(waveMessage),
			showConfirmButton: true,
			focusConfirm: false,
			confirmButtonText: '返信',
			showCancelButton: false,
			showCloseButton: true,
			preConfirm: () => {
				if ($("#EditWaveMessageReply").val().trim().length === 0) {
					return Swal.showValidationMessage('返信メッセージが空欄です');
				}
			}
		}).then((data)=> {
			const $EditWaveMessageReply = $("#EditWaveMessageReply");
			waveMessage.reply = $EditWaveMessageReply.val();
			if (data.dismiss) {
				return false;
			}

			//TODO send reply

			console.log(waveMessage.reply);
			waveMessage.replied = true;
		});
	}
</script>