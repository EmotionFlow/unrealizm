<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
	function getReplyEmojiInfoHtml() {
		return `
	<h3><i class="fas fa-reply" style="color: #3498db; margin-right: 10px;"></i>リプライ(β)</h3>
	<div style="text-align: left; font-size: 14px;">
	<p>もらったリアクションをタップすると、リアクションを送ってくれたユーザーに絵文字を返信できます。</p>
	<p>返信に使う絵文字は予め設定しておきます。（設定画面→絵文字）</p>
	<p>１リアクション１リプライです。連打しても複数送信されません。</p>
	</div>
	`;
	}

	function dispReplyEmojiInfo() {
		Swal.fire({
			html: getReplyEmojiInfoHtml(),
			focusConfirm: false,
			showCloseButton: true,
			showCancelButton: false,
		});
	}

	function switchEmojiReply(contentId, loginUserId, code) {
		const $IllustItem = $("#IllustItem_" + contentId);
		const $IllustItemResBtnList = $IllustItem.children(".IllustItemResBtnList");
		const $ResEmojiAdd = $IllustItem.find(".ResEmojiAdd");
		const $IllustItemReplyList = $IllustItem.children(".IllustItemReplyList");
		const $IllustItemReplyInfo = $IllustItem.children(".IllustItemReplyInfo");
		if (code === 1) {
			$IllustItemResBtnList.hide();
			$ResEmojiAdd.hide();
			$IllustItemReplyInfo.show();
		} else if(code === 2) {
			$IllustItemResBtnList.hide();
			$ResEmojiAdd.hide();
			$IllustItemReplyList.show();
			_getReplyEmojiHtml(contentId, loginUserId);
		} else if(code === 0) {
			$IllustItemReplyList.hide();
			$IllustItemReplyInfo.hide();
			$IllustItemResBtnList.show();
			$ResEmojiAdd.show();
		}
	}

	function _getReplyEmojiHtml(contentId, loginUserId) {
		if (contentId < 1 || loginUserId < 1) return false;

		const $ReplyEmojiList = $("#ReplyEmojiList_" + contentId);
		if ($ReplyEmojiList.children("span").length>0) return false;

		$.ajax({
			"type": "post",
			"data": {"ID": loginUserId, "TD": contentId},
			"url": "/f/GetReplyEmojiListF.jsp",
			"dataType": "json",
		}).then(
			(data) => {
				$ReplyEmojiList.html(data.html);
			},
			(jqXHR, textStatus, errorThrown) => {
				DispMsg('Connection error');
			}
		)
		return true;
	}

	function replyEmoji(_this) {
		return _replyEmoji(_this, <%=checkLogin.m_nUserId%>);
	}

	function DispReplyDone() { DispMsg("返信しました！", 500); }
	function DispAlreadyReplied() { DispMsg("返信済みです", 500); }

	function _replyEmoji(_this, loginUserId) {
		const $IllustItems = $(_this).parents(".IllustItem");
		const $IllustItemResBtnList = $IllustItems.children(".IllustItemResBtnList");
		if ($IllustItemResBtnList.css("display") !== "none") {
			return false;
		}
		const contentId = parseInt($IllustItems[0].id.split("_")[1], 10);
		const commentIdLast = parseInt($IllustItems.find(".LastCommentId").attr("value"), 10);
		const len = parseInt($(_this).parent().children("a.ResEmoji").length, 10);
		const commentIdOffset = len - $(_this).parent().children("a.ResEmoji").index($(_this)) - 1;
		console.log(contentId, commentIdLast, commentIdOffset);

		$.ajax({
			"type": "post",
			"data": {"IID": contentId, "UID": loginUserId, "CMTLST": commentIdLast, "CMTOFST": commentIdOffset},
			"url": "/f/ReplyEmojiF.jsp",
			"dataType": "json",
		}).then(
			(data) => {
				if (data.result === <%=Common.API_OK%>) {
					DispReplyDone();
					$(_this).addClass("Replied");
				} else if (data.error_code === <%=ReplyEmojiC.ERR_ALREADY_REPLIED%>) {
					DispAlreadyReplied();
					$(_this).addClass("Already");
				} else {
					DispMsg('Connection error');
				}
			},
			(jqXHR, textStatus, errorThrown) => {
				DispMsg('Connection error');
			}
		)
	}
</script>
