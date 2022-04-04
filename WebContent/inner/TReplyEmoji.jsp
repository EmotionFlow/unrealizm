<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
	function _getReplyEmojiInfoHtml() {
		return `
	<h3 class="ReplyEmojiInfoDlgTitle"><i class="fas fa-reply"></i><%=_TEX.T("ReplyEmoji")%></h3>
	<div class="ReplyEmojiInfoDlgBody">
	<p><%=_TEX.T("ReplyEmoji.Dlg.Info01")%></p>
	<p><%=_TEX.T("ReplyEmoji.Dlg.Info02." + (isApp ? "App" : "Browser"))%></p>
	<p><%=_TEX.T("ReplyEmoji.Dlg.Info03")%></p>
	</div>
	`;
	}

	function _getReplyEmojiInfoFooter() {
		return `<p><%=_TEX.T("ReplyEmoji.Dlg.Info04")%></p>`;
	}

	function replyEmoji(_this) {return _replyEmoji(_this, <%=checkLogin.m_nUserId%>);}
	function DispAlreadyReplied() { DispMsg("<%=_TEX.T("ReplyEmoji.Dlg.AlreadyReplied")%>", 500); }
	function DispNeedLogin() { DispMsg("<%=_TEX.T("ReplyEmoji.Dlg.NeedLogin")%>", 2000); }
	function DispReplyDone() { DispMsg("<%=_TEX.T("ReplyEmoji.Dlg.ReplyDone")%>", 500); }
</script>
