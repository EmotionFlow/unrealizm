<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	const waveMessages = {
		<%for (UserWave wave : cResults.myWaves) {%><%if (!wave.message.isEmpty()) {%>
		'<%=wave.id%>': {
			'emojiHtml': '<%=CEmoji.parse(wave.emoji)%>',
			'messageHtml': '<%=Util.toStringHtml(wave.message).replaceAll("'", "\\\\'")%>',
			'reply': `<%=Util.toQuotedString(wave.replyMessage, "`") %>`,
			'replied': <%=wave.replyMessage.isEmpty()?"false":"true"%>,
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
<div class="WaveMessageReplyTitle"><i class="fas fa-reply"></i> <%=_TEX.T("TWaveMessage.Reply.Title")%></div>
<div class="WaveMessageReplyText">
<textarea id="EditWaveMessageReply" maxlength="500" placeholder="<%=_TEX.T("TWaveMessage.Reply.CharLimit")%>">`+ waveMessage.reply +`</textarea>
</div>
</div>`;
		} else {
			html += `<div class="WaveMessageReply">
<div class="WaveMessageReplyTitle"><i class="fas fa-reply"></i> <%=_TEX.T("TWaveMessage.Reply.Already")%></div>
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
			showConfirmButton: !waveMessage.replied,
			focusConfirm: false,
			confirmButtonText: '返信',
			showCancelButton: false,
			showCloseButton: true,
			preConfirm: () => {
				if ($("#EditWaveMessageReply").val().trim().length === 0) {
					return Swal.showValidationMessage('<%=_TEX.T("TWaveMessage.Reply.Error.MessageEmpty")%>');
				}
			}
		}).then((data)=> {
			const $EditWaveMessageReply = $("#EditWaveMessageReply");
			waveMessage.reply = $EditWaveMessageReply.val();
			if (data.dismiss) {
				return false;
			}

			$.ajax({
				"type": "post",
				"data": {"ID": waveId, "MSG": waveMessage.reply},
				"url": "/f/SendUserWaveReplyF.jsp",
				"dataType": "json",
			}).then(
				(data) => {
					if (data.result === <%=Common.API_OK%>) {
						waveMessage.replied = true;
					}
					DispMsg(data.message);
				},
				(jqXHR, textStatus, errorThrown) => {
					DispMsg('Connection error');
				}
			)

		});
	}
</script>