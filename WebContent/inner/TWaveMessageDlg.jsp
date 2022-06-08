<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	const waveMessages = {
		<%for (UserWave wave : cResults.myWaves) {%><%if (!wave.message.isEmpty()) {%>
		'<%=wave.id%>': {
			'emojiHtml': '<%=CEmoji.parse(wave.emoji)%>',
			'messageHtml': '<%=Util.toStringHtml(wave.message).replaceAll("'", "\\\\'")%>',
			'reply': `<%=Util.toQuotedString(wave.replyMessage, "`") %>`,
			'replied': <%=wave.replyMessage.isEmpty()?"false":"true"%>,
			'isAnonymous' : <%=wave.fromUserId<0%>,
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
			.WaveAnonymous {
				display: block;
				font-size: 12px;
				margin-top: 18px;
			}
			.swal2-popup .swal2-styled.swal2-confirm {
				font-size: 14px;
			}
			.swal2-popup .swal2-footer {
				font-size: 12px;
				color: #7a7a7a;
			}
			</style>
		` + '<div class="WaveMessageDlg">' +
		'<div class="WaveEmoji">' + waveMessage.emojiHtml + '</div>' +
		'<div class="WaveMessage">' + waveMessage.messageHtml + '</div>';

		if (!waveMessage.isAnonymous) {
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
		} else {
			html += `<div class="WaveMessageReply"><span class="WaveAnonymous"><%=_TEX.T("TWaveMessage.Reply.Anonymous")%></span></div>`;
		}
		html += '</div>';
		return html;
	}

	function showWaveMessage(waveId) {
		const waveMessage = waveMessages[waveId];
		if (!waveMessage) return false;
		Swal.fire({
			html: getWaveMessageDlgHtml(waveMessage),
			showConfirmButton: !waveMessage.isAnonymous && !waveMessage.replied,
			focusConfirm: false,
			confirmButtonText: '<%=_TEX.T("TWaveMessage.Reply.Submit")%>',
			showCancelButton: false,
			showCloseButton: true,
			footer: '<%=_TEX.T("TWaveMessage.Reply.Info")%>',
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


	const waveReplies = {
		<%for (MyIllustListC.ReplyWave reply : cResults.replyWaves) {%>
		'<%=reply.wave.id%>': {
			'emojiHtml': '<%=CEmoji.parse(reply.wave.emoji)%>',
			'messageHtml': '<%=Util.toStringHtml(reply.wave.message).replaceAll("'", "\\\\'")%>',
			'reply': '<%=Util.toStringHtml(reply.wave.replyMessage).replaceAll("'", "\\\\'")%>',
			'replied': true,
			'user': {
				'id': <%=reply.replyUserId%>,
				'nickName': '<%=Util.toStringHtml(reply.replyUserNickname).replaceAll("'", "\\\\'")%>',
				'profImgUrl': '<%=reply.replyUserProfImgUrl%>'
			}
		},
		<%}%>
	}


	function getReplyWaveMessageDlgHtml(waveReply) {
		let html =  `
			<style>
			.WaveReplyUser {
				display: flex;
				flex-direction: row;
				align-items: center;
			}
			.WaveReplyUserThumb {
				display: block;
				width: 40px;
				height: 40px;
				margin: 10px 0;
				overflow: hidden;
				border: solid 1px #ccc;
				border-radius:20px;
				background-size: cover;
				background-position: 50% 50%;
				background-color: #fff;
			}
			.WaveReplyUserNickname{
				margin-left: 5px;
			}
			</style>
		` + '<div class="WaveMessageDlg">' +
			'<div class="WaveReplyUser">' +
			'<a class="WaveReplyUserThumb" style="background-image: url(\'' + waveReply.user.profImgUrl + '\')" href="/' + waveReply.user.id + '/"></a>' +
			'<span class="WaveReplyUserNickname">' + waveReply.user.nickName + '</span>' +
			'</div>' +
			'<div class="WaveMessage">' + waveReply.reply + '</div>' +
			'<div class="WaveEmoji" style="margin-top: 13px;">' + waveReply.emojiHtml + '</div>' +
			'<div class="WaveMessage">' + waveReply.messageHtml + '</div>' +
			'</div>';
		return html;
	}

	function showReplyWaveMessage(waveId) {
		const waveReply = waveReplies[waveId];
		if (!waveReply) return false;
		Swal.fire({
			html: getReplyWaveMessageDlgHtml(waveReply),
			showConfirmButton: false,
			showCancelButton: false,
			showCloseButton: true,
		});
	}

</script>