<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
function getReplyEmojiInfoHtml() {
	return `
	<h3><i class="fas fa-reply" style="margin-right: 10px;"></i>リプライ(β)</h3>
	<div style="text-align: left; font-size: 14px;">
	<p>もらったリアクションをタップすると、送ってくれた相手に作者からの絵文字として通知されます。</p>
	<p>返信絵文字は１文字固定です。使いたい絵文字を設定画面で変更できます。</p>
	<p>まとめて返信ボタンをタップすると、まだ返信していないリアクションにまとめて返信できます。</p>
	</div>
	`;
}
function dispReplyEmojiInfo() {
	Swal.fire({html: getReplyEmojiInfoHtml(), focusConfirm: false, showCloseButton: true, showCancelButton: false,});
}

function switchEmojiReply(_this) {
	let $IllustItemResBtnList = $(_this).parent().parent();
	let $ResEmojiAdd = $IllustItemResBtnList.parent().find(".ResEmojiAdd");
	let $IllustItemReplyList = $IllustItemResBtnList.parent().children(".IllustItemReplyList");
	if ($IllustItemReplyList.css("display") === "none") {
		$IllustItemResBtnList = $(_this).parent().parent();
		$ResEmojiAdd = $IllustItemResBtnList.parent().find(".ResEmojiAdd");
		$IllustItemReplyList = $IllustItemResBtnList.parent().children(".IllustItemReplyList");
		$IllustItemResBtnList.hide();
		$ResEmojiAdd.hide();
		$IllustItemReplyList.show();
	} else {
		$IllustItemReplyList = $(_this).parent();
		$IllustItemResBtnList = $(_this).parent().parent().children(".IllustItemResBtnList");
		$ResEmojiAdd = $IllustItemResBtnList.parent().find(".ResEmojiAdd");
		$IllustItemReplyList.hide();
		$IllustItemResBtnList.show();
		$ResEmojiAdd.show();
	}
}

function replyEmoji(_this) {
	const $IllustItems = $(_this).parents(".IllustItem");
	const $IllustItemResBtnList = $IllustItems.children(".IllustItemResBtnList");
	if ($IllustItemResBtnList.css("display") !== "none") {
		return false;
	}
	const contentId = parseInt($IllustItems[0].id.split("_")[1], 10);
	const lastCommentId = parseInt($IllustItems.find(".LastCommentId").attr("value"), 10);
	const len = parseInt($(_this).parent().children(".ResEmoji").length, 10);
	const commentIdOffset = len - $(_this).parent().children(".ResEmoji").index($(_this)) - 1;
	console.log(contentId, lastCommentId, commentIdOffset);
}


</script>
