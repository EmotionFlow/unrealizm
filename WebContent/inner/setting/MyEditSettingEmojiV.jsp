<%@page import="jp.pipa.poipiku.CUser"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	StringBuilder sb = new StringBuilder();
	for(String emoji : Emoji.EMOJI_ALL) {
		sb.append(
				String.format("<span class=\"EmojiBtn\" onclick=\"\">%s</span>",
						CEmoji.parse(emoji))
		);
	}
	final String allEmojiHtml = sb.toString();
%>


<script type="text/javascript">
	function UpdateNgReaction() {
		var bMode = $('#NgReaction').prop('checked');
		$.ajaxSingle({
			"type": "post",
			"data": { "UID": <%=checkLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.REACTION_HIDE%>:<%=CUser.REACTION_SHOW%> },
			"url": "/f/UpdateNgReactionF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}
</script>

<style>
	.EmojiBtnList {
		height: 300px;
		overflow: scroll;
        border: solid 1px lightgray;
	}
	.EmojiBtn {
        display: inline-block;
        overflow: hidden;
        text-align: center;
        font-size: 20px;
        background: #fff;
        width: 35px;
        height: 35px;
        line-height: 35px;
        margin: 4px 2px 0 5px;
        border-radius: 100px;
        user-select: none;
        font-family: EmojiFontFamily,'Apple Color Emoji',sans-serif;
        cursor: pointer;
	}
    .EmojiBtn > .Twemoji {
        width: 22px;
        height: auto;
    }
</style>
<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle">リアクション用絵文字</div>
		<div class="SettingBody">
			<div class="EmojiBtnList">
				<%=allEmojiHtml%>
			</div>
			<div class="SettingBodyCmd">
				<span class="BtnBase SettingBodyCmdRegist">
					<%=_TEX.T("EditSettingV.Image.Select")%>
					<input class="CmdRegistSelectFile" type="file" name="file_header" id="file_header" onchange="UpdateProfileHeaderFile(this)" />
				</span>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(2)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
			</div>
		</div>
	</div>
</div>
