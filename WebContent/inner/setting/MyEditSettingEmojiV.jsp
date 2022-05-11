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
		$(".Wave > .EmojiBtn").click( ev => {
			if ($("#SelectedWaveEmoji > .Twemoji").length === 4) {
				return false;
			}
			$("#SelectedWaveEmoji").append($(ev.currentTarget).html());
		});
		$(".Reply > .EmojiBtn").click( ev => {
			$("#SelectedReplyEmoji").html($(ev.currentTarget).html());
		});
	})

	function deleteWaveEmoji(){
		if ($("#SelectedWaveEmoji > .Twemoji").length === 0) {
			return false;
		}
		$("#SelectedWaveEmoji > .Twemoji:last-child").remove();
	}

	function updateWaveEmoji() {
		let waveEmojiAll = "";
		const $imgList = $('#SelectedWaveEmoji > img');
		for (let elImg of $imgList) {
			waveEmojiAll += elImg.getAttribute('alt');
		}
		const postData = {
			"UID": <%=checkLogin.m_nUserId%>,
			"EMOJI" : waveEmojiAll,
		}
		$.ajaxSingle({
			"type": "post",
			"data": postData,
			"url": "/f/UpdateUserWaveEmojiF.jsp",
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
    .SettingList .SettingListItem .SettingBody .SettingBodyCmd .RegistMessage {
        display: flex;
    }
    .SelectedEmoji{
		margin: 5px 0;
    }
    .SelectedEmoji > .Twemoji{
        width: 32px;
        height: 32px;
    }

    #SelectedWaveEmoji {
        display: flex;
    }
    #SelectedWaveEmoji > .Twemoji {
        margin: 0 6px;
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
    .DeleteButton {
		font-size: 20px;
		color: #4ca9ac;
		font-weight: bold;
	}

</style>
<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingEmojiV.Wave.Title")%></div>
		<div class="SettingBody">
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div id="SelectedWaveEmoji" class="SelectedEmoji">
						<%if(myEditSettingEmojiC.userWaveTemplateList.isEmpty()){%>
							<%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[0])%>
							<%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[1])%>
							<%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[2])%>
							<%=CEmoji.parse(Emoji.USER_WAVE_EMOJI_DEFAULT[3])%>
						<%}else{%>
							<%for (UserWaveTemplate wave: myEditSettingEmojiC.userWaveTemplateList) {%>
							<%=CEmoji.parse(wave.chars)%>
							<%}%>
						<%}%>
					</div>
					<div class="DeleteButton" onclick="deleteWaveEmoji()">⌫</div>
				</div>
				<div class="SettingBodyCmd">
					<a class="BtnBase SettingBodyCmdRegist"
					   href="javascript:void(0)"
					   onclick="updateWaveEmoji()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
				</div>
			</div>
			<div class="EmojiBtnList Wave">
				<%=allEmojiHtml%>
			</div>
		</div>
	</div>
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingEmojiV.Reply.Title")%></div>
		<div class="SettingBody">
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div id="SelectedReplyEmoji" class="SelectedEmoji">
						<%=CEmoji.parse(myEditSettingEmojiC.commentTemplate.chars)%>
					</div>
				</div>
				<div class="SettingBodyCmd">
					<a class="BtnBase SettingBodyCmdRegist"
					   href="javascript:void(0)"
					   onclick="updateReplyEmoji($('#SelectedReplyEmoji > img').attr('alt'))"><%=_TEX.T("EditSettingV.Button.Update")%></a>
				</div>
			</div>
			<div class="EmojiBtnList Reply">
				<%=allEmojiHtml%>
			</div>
		</div>
	</div>
</div>
