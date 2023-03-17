<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.controller.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function UpdateNickName() {
		var strUserName = $.trim($("#RegistUserName").val());
		if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
			DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
			return;
		}
		$.ajaxSingle({
			"type": "post",
			"data": { "ID":<%=checkLogin.m_nUserId%>, "NN":strUserName},
			"url": "/f/UpdateNickNameF.jsp",
			"dataType": "json",
			"success": function(data) {
					DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Ok")%>");
			},
			"error": function(req, stat, ex){
					DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
		});
		return false;
	}

	function DispDescCharNum() {
		var nCharNum = 1000 - $("#EditBio").val().length;
		$("#ProfileTextMessage").html(nCharNum);
	}

	function UpdateProfileFile(objTarg){
		updateFile("/f/UpdateProfileFileF.jsp", objTarg, 1.0);
	}

	function UpdateProfileTxt() {
		var strProfileTxt = $.trim($("#EditBio").val());
		$.ajaxSingle({
			"type": "post",
			"data": { "ID":<%=checkLogin.m_nUserId%>, "DES":strProfileTxt},
			"url": "/f/UpdateProfileTxtF.jsp",
			"dataType": "json",
			"success": function(data) {
				DispMsg("<%=_TEX.T("EditSettingV.Upload.Updated")%>");
				sendObjectMessage("reloadParent");
			},
			"error": function(req, stat, ex){
				DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");
			}
		});
		return false;
	}

	$(function () {
		DispDescCharNum();
	})
</script>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("Twitter.Share.MyUrl")%></div>
		<div class="SettingBody">
			<a href="https://unrealizm.com/<%=checkLogin.m_nUserId%>/"
			style="font-size: 14px; text-decoration: underline;">
				https://unrealizm.com/<%=checkLogin.m_nUserId%>/
			</a>
			<div class="SettingBodyCmd">
				<%
					String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
							URLEncoder.encode(String.format("%s%s #%s",
									checkLogin.m_strNickName,
									_TEX.T("Twitter.UserAddition"),
									_TEX.T("Common.HashTag")), "UTF-8"),
							URLEncoder.encode("https://unrealizm.com/"+checkLogin.m_nUserId+"/", "UTF-8"));

				%>
				<a class="BtnBase" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
			</div>
		</div>
	</div>

	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.NickName")%></div>
		<div class="SettingBody">
			<input id="RegistUserName" class="SettingBodyTxt" type="text" placeholder="<%=_TEX.T("EditSettingV.NickName.PlaceHolder")%>" value="<%=Util.toStringHtml(results.m_cUser.m_strNickName)%>" maxlength="16" />
			<div id="RegistUserNameMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.NickName.Message.Empty")%></div>
			<div class="SettingBodyCmd">
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNickName()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>
	</div>

	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Image")%></div>
		<div class="SettingBody">
			<div class="PreviewImgFrame">
				<%if(results.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
				<span class="PreviewMessage"><%=_TEX.T("EditSettingV.Image.NoImage")%></span>
				<%} else {%>
				<img class="PreviewImg" src="<%=Common.GetUrl(results.m_cUser.m_strFileName)%>" />
				<%}%>
			</div>
			<div id="RegistPreviewImgMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.Image.Format")%></div>
			<div class="SettingBodyCmd">
				<span class="BtnBase SettingBodyCmdRegist">
					<%=_TEX.T("EditSettingV.Image.Select")%>
					<input class="CmdRegistSelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateProfileFile(this)" />
				</span>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(1)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
			</div>
		</div>
	</div>

	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Bio")%></div>
		<div class="SettingBody">
			<textarea id="EditBio" class="SettingBodyTxt" rows="6" onkeyup="DispDescCharNum()" maxlength="1000"><%=Util.toStringHtmlTextarea(results.m_cUser.m_strProfile)%></textarea>
			<div class="SettingBodyCmd">
				<div id="ProfileTextMessage" class="RegistMessage" >1000</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateProfileTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>
	</div>

	<div class="SettingListItem" style="border: none;">
		<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.PublishAccount")%></div>
		<div class="SettingBody">
			<p><%=_TEX.T("EditSettingV.Twitter.PublishAccount.Info1")%></p>
			<div class="SettingBodyCmd">
				<div class="RegistMessage" >
					<div class="onoffswitch OnOff">
						<input type="checkbox" name="AutoTweet" class="onoffswitch-checkbox" id="PublishAccount" value="1" <%if(results.m_cUser.m_nTwitterAccountPublicMode==CUser.TW_PUBLIC_ON){%>checked="checked"<%}%> />
						<label class="onoffswitch-label" for="PublishAccount">
							<span class="onoffswitch-inner"></span>
							<span class="onoffswitch-switch"></span>
						</label>
					</div>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateTwitterPublishAccount()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>
	</div>
</div>
