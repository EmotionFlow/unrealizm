<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
	function getReplyEmojiInfoHtml() {
		return `
	<h3 class="ReplyEmojiInfoDlgTitle"><i class="fas fa-reply"></i>リプライ(β)</h3>
	<div class="ReplyEmojiInfoDlgBody">
	<p>もらったリアクションをタップすると、リアクションを送ってくれたユーザーに絵文字を返信できます。</p>
	<p>返信に使う絵文字は設定画面→絵文字にて変更できます。</p>
	<p>１リアクション１リプライまでです。連打しても複数送信されません。</p>
	</div>
	`;
	}
	function replyEmoji(_this) {
		return _replyEmoji(_this, <%=checkLogin.m_nUserId%>);
	}
	function DispReplyDone() { DispMsg("返信しました！", 500); }
	function DispAlreadyReplied() { DispMsg("返信済みです", 500); }
</script>
