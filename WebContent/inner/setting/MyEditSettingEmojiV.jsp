<%@page import="jp.pipa.poipiku.CUser"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
StringBuilder sb = new StringBuilder();
for(String emoji : Emoji.EMOJI_ALL) {
	sb.append(
			String.format("<span class=\"EmojiBtn\">%s</span>",
					CEmoji.parse(emoji))
	);
}
final String allEmojiHtml = sb.toString();

MyEditSettingEmojiC myEditSettingEmojiC = new MyEditSettingEmojiC();
myEditSettingEmojiC.getResults(checkLogin);

%>


<script type="text/javascript">
	$(()=>{
		$(".EmojiBtn").click( ev => {
			$("#SelectedEmoji").html($(ev.currentTarget).html());
		})
	})

	function updateReplyEmoji(emoji) {
		const postData = {
			"UID": <%=checkLogin.m_nUserId%>,
			"ORDER" : 0,
			"EMOJI" : emoji,
		}
		$.ajaxSingle({
			"type": "post",
			"data": postData,
			"url": "/f/UpdateReplyEmojiF.jsp",
			"dataType": "json",
			"success": function(data) {
				if (data.result === 1)
					DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
				else
					DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			},
			"error": function(req, stat, ex){
				DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
			}
		});
		return false;
	}
</script>

<style>
	.RegistMessage {
        display: flex;
        justify-content: space-between;
    }
    #SelectedEmoji{
		margin: 5px auto;
    }
    #SelectedEmoji > .Twemoji{
        width: 32px;
        height: 32px;
    }
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
		<div class="SettingListTitle">こっそリプライ絵文字</div>
		<div class="SettingBody">
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div id="SelectedEmoji">
						<%=CEmoji.parse(myEditSettingEmojiC.commentTemplate.chars)%>
					</div>
				</div>
				<div class="SettingBodyCmd">
					<a class="BtnBase SettingBodyCmdRegist"
					   href="javascript:void(0)"
					   onclick="updateReplyEmoji($('#SelectedEmoji > img').attr('alt'))"><%=_TEX.T("EditSettingV.Button.Update")%></a>
				</div>
			</div>
			<div class="EmojiBtnList">
				<%=allEmojiHtml%>
			</div>
		</div>
	</div>
</div>
