<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

//パラメータの取得
//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.GetParam(request);
cResults.GetResults(cCheckLogin);

String strEmailState = "";
if(cResults.m_bUpdate) {
	strEmailState = _TEX.T("EditSettingV.Email.EmailState.Confirmation") + cResults.m_strNewEmail;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		</script>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});
			function CheckInput() {
				var bRtn = true;
				var strMessage = "&nbsp;";
				try {
					var strUserName = $.trim($("#RegistUserName").val());
					if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
						strMessage = "<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>";
						bRtn = false;
					}
				} finally {
					$("#UserNameMessage").html(strMessage);
				}
				return bRtn;
			}

			function UpdateNickName() {
				var strUserName = $.trim($("#RegistUserName").val());
				if(strUserName.length<<%=UserAuthUtil.LENGTH_NICKNAME_MIN%> || strUserName.length><%=UserAuthUtil.LENGTH_NICKNAME_MAX%>) {
					DispMsg("<%=_TEX.T("EditSettingV.NickName.Message.Empty")%>");
					return;
				}
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "NN":strUserName},
					"url": "/f/UpdateNickNameF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('<%=_TEX.T("EditSettingV.NickName.Message.Ok")%>');
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function updateFile(url, objTarg){
				if (objTarg.files.length>0 && objTarg.files[0].type.match('image.*')) {
					DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
					var fileReader = new FileReader();
					fileReader.onloadend = function() {
						var strEncodeImg = fileReader.result;
						var mime_pos = strEncodeImg.substring(0, 100).indexOf(",");
						if(mime_pos==-1) return;
						strEncodeImg = strEncodeImg.substring(mime_pos+1);
						$.ajaxSingle({
							"type": "post",
							"data": {"UID":<%=cCheckLogin.m_nUserId%>, "DATA":strEncodeImg},
							"url": url,
							"dataType": "json",
							"success": function(res) {
								switch(res.result) {
								case 0:
									// complete
									DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
									sendObjectMessage("reloadParent");
									location.reload(true);
									break;
								case -1:
									// file size error
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
									break;
								case -2:
									// file type error
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
									break;
								default:
									DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + res.result);
									break;
								}
							},
							"error": function(req, stat, ex){
								DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
							}
						});
					}
					fileReader.readAsDataURL(objTarg.files[0]);
				}
				return false;
			}

			function UpdateProfileFile(objTarg){
				updateFile("/f/UpdateProfileFileF.jsp", objTarg);
			}

			function UpdateProfileHeaderFile(objTarg){
				updateFile("/f/UpdateProfileHeaderFileF.jsp", objTarg);
			}

			function UpdateProfileBgFile(objTarg){
				updateFile("/f/UpdateProfileBgFileF.jsp", objTarg);
			}

			function ResetProfileFile(nMode){
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "MD":nMode},
					"url": "/f/ResetProfileFileF.jsp",
					"dataType": "json",
					"success": function(data) {
						sendObjectMessage("reloadParent");
						location.reload(true);
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function DispDescCharNum() {
				var nCharNum = 1000 - $("#EditBio").val().length;
				$("#ProfileTextMessage").html(nCharNum);
			}

			function UpdateProfileTxt() {
				var strProfileTxt = $.trim($("#EditBio").val());
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>, "DES":strProfileTxt},
					"url": "/f/UpdateProfileTxtF.jsp",
					"dataType": "json",
					"success": function(data) {
						DispMsg('<%=_TEX.T("EditSettingV.Upload.Updated")%>');
						sendObjectMessage("reloadParent");
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function DispMuteCharNum() {
				var nCharNum = 100 - $("#MuteKeywordText").val().length;
				$("#MuteKeywordTextNum").html(nCharNum);
			}

			function UpdateMuteKeyword() {
				var strMuteKeywordTxt = $.trim($("#MuteKeywordText").val());
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "DES": strMuteKeywordTxt },
					"url": "/f/UpdateMuteKeywordF.jsp",
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

			function UpdateNgReaction() {
				var bMode = $('#NgReaction').prop('checked');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "MID": (bMode)?<%=CUser.REACTION_HIDE%>:<%=CUser.REACTION_SHOW%> },
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

			function DeregistTwitter() {
				$.ajaxSingle({
					"type": "post",
					"data": { "ID":<%=cCheckLogin.m_nUserId%>},
					"url": "/f/DeregistTwitterF.jsp",
					"dataType": "json",
					"success": function(data) {
						location.reload(true);
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
				return false;
			}

			function UpdateAutoTweet() {
				var bAutoTweet = $('#AutoTweet').prop('checked');
				var nAutoTweetWeekDay = parseInt($('#AutoTweetWeekDay').val(), 10);
				var nAutoTweetTime = parseInt($('#AutoTweetTime').val(), 10);
				var strAutoTweetTxt = $.trim($("#AutoTweetTxt").val());
				var nAutoTweetThumbNum = ($('#AutoTweetThumb').prop('checked'))?9:0;
				if(!bAutoTweet) {
					nAutoTweetWeekDay = -1;
					nAutoTweetTime = -1;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {
						"ID": <%=cCheckLogin.m_nUserId%>,
						"AW": nAutoTweetWeekDay,
						"AT": nAutoTweetTime,
						"AD": strAutoTweetTxt,
						"ATN": nAutoTweetThumbNum},
					"url": "/f/UpdateAutoTweetF.jsp",
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

			function DispAutoTweetCharNum() {
				var nCharNum = 100 - $("#AutoTweetTxt").val().length;
				$("#AutoTweetTxtNum").html(nCharNum);
			}

			function UpdateEmailAddress(){
				var strEmail = $("#EM").val();
				if(!strEmail.match(/^([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+$/)) {
					DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Empty")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {"ID": <%=cCheckLogin.m_nUserId%>, "EM": strEmail},
					"url": "/f/UpdateEmailAddressF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log(data);
						if(data.result>0) {
							DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Confirmation")%>');
						} else {
							DispMsg('<%=_TEX.T("EditSettingV.Email.Message.Exist")%>');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
			}

			function UpdatePassword(){
				var PW = $("#PW").val();
				var PW1 = $("#PW1").val();
				var PW2 = $("#PW2").val();
				if(PW1.length<4 || PW1.length>16) {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Empty")%>');
					return false;
				}
				if(PW1!=PW2) {
					DispMsg('<%=_TEX.T("EditSettingV.Password.Message.NotMatch")%>');
					return false;
				}
				$.ajaxSingle({
					"type": "post",
					"data": {"ID": <%=cCheckLogin.m_nUserId%>, "PW": PW, "PW1": PW1, "PW2": PW2},
					"url": "/f/UpdatePasswordF.jsp",
					"dataType": "json",
					"success": function(data) {
						console.log(data);
						if(data.result>0) {
							DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Ok")%>');
						} else {
							DispMsg('<%=_TEX.T("EditSettingV.Password.Message.Wrong")%>');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
			}

			function Logout() {
				$.ajaxSingle({
					"type": "post",
					"data": {"ID":<%=cCheckLogin.m_nUserId%>},
					"url": "/f/LogioutF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result>0) {
							deleteCookie('POIPIKU_LK');
							location.href="/";
						}
					},
					"error": function(req, stat, ex){
						DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
					}
				});
			}

			function CheckDeregist(){
				if(!$("#CheckDeregistCheckBox").prop('checked')) return;
				if(window.confirm('<%=_TEX.T("EditSettingV.DeleteAccount.CheckDeregist")%>')){
					$.ajaxSingle({
						"type": "post",
						"data": {"ID":<%=cCheckLogin.m_nUserId%>},
						"url": "/f/DeleteUserF.jsp",
						"dataType": "json",
						"success": function(data) {
							if(data.result>0) {
								deleteCookie('POIPIKU_LK');
								location.href="/";
							}
						},
						"error": function(req, stat, ex){
							DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%>');
						}
					});
				}
			}

			function CheckDeregist_checkbox() {
				if ($("#CheckDeregistCheckBox").prop('checked')) {
					$("#CheckDeregist").prop("disabled", false);
					$("#CheckDeregist").removeClass("Disabled");
				} else {
					$("#CheckDeregist").prop("disabled", true);
					$("#CheckDeregist").addClass("Disabled");
				}
			}
			$(function(){
				$("#MySetting").addClass("Selected");

				DispDescCharNum();
				DispMuteCharNum();
				DispAutoTweetCharNum();

				<%if(cResults.m_strMessage.length()>0) {%>
				DispMsg("<%=Common.ToStringHtml(cResults.m_strMessage)%>");
				<%}%>
			});
		</script>

		<style>
		.UserInfo .UserInfoUser .UserInfoUserThumbEdit {
			display: block;
			width: 84px;
			height: 84px;
			overflow: hidden;
			margin: -42px auto 0 auto;
			background-size: cover;
			position: relative;
		}

		.UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImg {
			background-image: url(//img.poipiku.com/img/default_user.jpg);
			border-radius: 80px;
			border: solid 2px #ccc;
			width: 80px;
			height: 80px;
			background-color: #fff;
			margin: 0 auto 0 auto;
			background-position: 50% 50%;
		}

		.UserInfo .UserInfoUser .UserInfoUserThumbEdit .UserInfoUserImgUpload {
			background: url(/img/menu_pc-03.png) no-repeat;
			background-position: -30px 0px;
			background-size: 450px;
			background-color: #fff;
			width: 30px;
			height: 30px;
			top: 50px;
			left: 50px;
			overflow: overlay;
			position: absolute;
			border-radius: 30px;
			border: solid 2px #ccc;
		}
		.UserInfo .UserInfoBg .UserInfoBackgroundUpload {
			background: url(/img/menu_pc-03.png) no-repeat;
			background-position: -30px 0px;
			background-size: 450px;
			background-color: #fff;
			width: 30px;
			height: 30px;
			top: 4px;
			right: 4px;
			overflow: overlay;
			position: absolute;
			border-radius: 30px;
			border: solid 2px #ccc;
		}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="UserInfo Float">
				<div class="UserInfoBg" style="position: relative;">
					<div class="UserInfoBackgroundUpload"></div>
				</div>
				<section class="UserInfoUser">
					<div class="UserInfoUserThumbEdit">
						<div class="UserInfoUserImg"></div>
						<div class="UserInfoUserImgUpload"></div>
					</div>
					<h2 class="UserInfoUserName">
						<div class="SettingBody">
							<input id="RegistUserName" class="SettingBodyTxt" type="text" placeholder="<%=_TEX.T("EditSettingV.NickName.PlaceHolder")%>" value="<%=Common.ToStringHtml(cResults.m_cUser.m_strNickName)%>" maxlength="16" onkeyup="CheckInput()" />
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNickName()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
							<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
						</div>
					</h2>
					<h3 class="UserInfoProgile"><%=Common.AutoLink(Common.ToStringHtml(cResults.m_cUser.m_strProfile), cResults.m_cUser.m_nUserId, CCnv.MODE_PC)%></h3>
					<span class="UserInfoCmd">
						<%
						String strTwitterUrl=String.format("https://twitter.com/intent/tweet?text=%s&url=%s",
								URLEncoder.encode(String.format("%s%s %s #%s",
										cResults.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										String.format(_TEX.T("Twitter.UserPostNum"), cResults.m_nPublishedContentsTotal),
										_TEX.T("Common.Title")), "UTF-8"),
								URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"));
						%>
						<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
						<a class="BtnBase UserInfoCmdFollow" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
						<span class="IllustItemCommandSub">
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
						</span>
					</span>
				</section>
				<section class="UserInfoState">
					<a class="UserInfoStateItem Selected" href="/<%=cResults.m_cUser.m_nUserId%>/">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.ContentNum")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_nPublishedContentsTotal%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowListPcV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
				</section>
			</div>

			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.NickName")%></div>
					<div class="SettingBody">
						<input id="RegistUserName" class="SettingBodyTxt" type="text" placeholder="<%=_TEX.T("EditSettingV.NickName.PlaceHolder")%>" value="<%=Common.ToStringHtml(cResults.m_cUser.m_strNickName)%>" maxlength="16" onkeyup="CheckInput()" />
						<div class="SettingBodyCmd">
							<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNickName()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Image")%></div>
					<div class="SettingBody" style="text-align: center;">
						<div class="FileSelectFrame" style="display: inline-block; width: 124px;height: 124px;border: solid 2px #eee; border-radius: 120px; overflow: hidden;display: inline-block;float: none;">
							<%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: 124px 124px;border-radius: 120px; overflow: hidden; background-size: cover; background-position: 50% 50%; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>');"></div>
							<%}%>
							<input class="SelectFile" type="file" name="file_thumb" id="file_thumb" onchange="UpdateProfileFile(this)" />
							<%if(cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;"><%=_TEX.T("EditSettingV.Image.Saving")%></span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.Image.Format")%></div>
							<%if(!cResults.m_cUser.m_strFileName.equals("/img/default_user.jpg")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(1)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.HeaderImage")%></div>
					<div class="SettingBody">
						<div class="FileSelectFrame" style="border: solid 1px #eee;">
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: 100% auto; background-repeat: no-repeat; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');"></div>
							<input class="SelectFile" type="file" name="file_header" id="file_header" onchange="UpdateProfileHeaderFile(this)" />
							<%if(cResults.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;"><%=_TEX.T("EditSettingV.Image.Saving")%></span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage.Format")%></div>
							<%if(!cResults.m_cUser.m_strHeaderFileName.equals("/img/default_transparency.gif")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(2)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem" style="display: none;">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.BgImage")%></div>
					<div class="SettingBody">
						<div class="FileSelectFrame" style="border: solid 1px #eee;">
							<div style="position: absolute; top:0; left: 0; width: 100%; height: 100%; background-size: cover; background-repeat: no-repeat; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>?<%=Math.random()%>');"></div>
							<input class="SelectFile" type="file" name="file_bg" id="file_bg" onchange="UpdateProfileBgFile(this)" />
							<%if(cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
							<span class="typcn typcn-plus-outline"></span>
							<%} else {%>
							<span style="text-shadow: none; color: #6d6965;"><%=_TEX.T("EditSettingV.Image.Saving")%></span>
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<div id="ProfileImageMessage" class="RegistMessage" ><%=_TEX.T("EditSettingV.HeaderImage.Format")%></div>
							<%if(!cResults.m_cUser.m_strBgFileName.equals("/img/default_transparency.gif")) {%>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="ResetProfileFile(3)"><%=_TEX.T("EditSettingV.Image.Default")%></a>
							<%}%>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Bio")%></div>
					<div class="SettingBody">
						<textarea id="EditBio" class="SettingBodyTxt" rows="6" onkeyup="DispDescCharNum()" maxlength="1000"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strProfile)%></textarea>
						<div class="SettingBodyCmd">
							<div id="ProfileTextMessage" class="RegistMessage" >1000</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateProfileTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.MuteKeyowrd")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.MuteKeyowrd.Message")%>
						<textarea id="MuteKeywordText" class="SettingBodyTxt" rows="6" onkeyup="DispMuteCharNum()" maxlength="100" placeholder="<%=_TEX.T("EditSettingV.MuteKeyowrd.PlaceHolder")%>"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strMuteKeyword)%></textarea>
						<div class="SettingBodyCmd">
							<div id="MuteKeywordTextNum" class="RegistMessage" >100</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateMuteKeyword()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.ReactionMode")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.ReactionMode.Message")%>
						<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
							<div class="RegistMessage" >
								<div class="onoffswitch OnOff">
									<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="NgReaction" value="0" <%if(cResults.m_cUser.m_nReaction!=CUser.REACTION_SHOW){%>checked="checked"<%}%> />
									<label class="onoffswitch-label" for="NgReaction">
										<span class="onoffswitch-inner"></span>
										<span class="onoffswitch-switch"></span>
									</label>
								</div>
								<script>
								$('#NgReaction').change(function(){
									//UpdateDispFollowerLink();
								});
								</script>
							</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateNgReaction()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<a id="TwitterSetting" name="TwitterSetting"></a>
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.Twitter.Info")%>
						<div class="SettingBodyCmd">
							<div class="RegistMessage" >[<%=(cResults.m_cUser.m_bTweet)?String.format(_TEX.T("EditSettingV.Twitter.Info.State.On"), cResults.m_cUser.m_strTwitterScreenName):_TEX.T("EditSettingV.Twitter.Info.State.Off")%>]</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="location.href='/TokenFormTwitterPc.jsp'"><%=_TEX.T("EditSettingV.Twitter.Button")%></a>
						</div>
						<%if(cResults.m_cUser.m_bTweet){%>
						<!--
						<div class="SettingBodyCmd">
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="DeregistTwitter()"><%=_TEX.T("EditSettingV.Twitter.Button.Deregist")%></a>
						</div>
						-->
						<%}%>
					</div>
				</div>

				<%if(cResults.m_cUser.m_bTweet){%>
				<div id="SectionAutoTweet" class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Twitter.Auto")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.Twitter.Auto.Info")%>
						<div class="SettingBodyCmd">
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="AutoTweet" class="onoffswitch-checkbox" id="AutoTweet" value="1" <%if(cResults.m_cUser.m_nAutoTweetTime>=0){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AutoTweet">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
							<script>
							$('#AutoTweet').change(function(){
								var bAutoTweet = $('#AutoTweet').prop('checked');
								$('#AutoTweetWeekDay').prop('disabled', !bAutoTweet);
								$('#AutoTweetTime').prop('disabled', !bAutoTweet);
								$('#AutoTweetTxt').prop('disabled', !bAutoTweet);
								$('#AutoTweetThumb').prop('disabled', !bAutoTweet);
								//UpdateAutoTweet();
							});
							</script>
						</div>
						<div class="SettingBodyCmd">
							<select id="AutoTweetWeekDay" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
								<option value="-1"><%=_TEX.T("EditSettingV.Twitter.Auto.WeekDay.DayEvery")%></option>
								<%for(int nTime=0; nTime<7; nTime++) {%>
								<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetWeekDay==nTime){%>selected="selected"<%}%>><%=_TEX.T(String.format("EditSettingV.Twitter.Auto.WeekDay.Day%d", nTime))%></option>
								<%}%>
							</select>
						</div>
						<div class="SettingBodyCmd">
							<select id="AutoTweetTime" class="AutoTweetPullDown" <%if(cResults.m_cUser.m_nAutoTweetTime<0){%>disabled="disabled"<%}%>>
								<%for(int nTime=0; nTime<24; nTime++) {%>
								<option value="<%=nTime%>" <%if(cResults.m_cUser.m_nAutoTweetTime==nTime){%>selected="selected"<%}%>><%=nTime%><%=_TEX.T("EditSettingV.Twitter.Auto.Unit")%></option>
								<%}%>
							</select>
						</div>
						<div class="SettingBodyCmd">
							<%if(cResults.m_cUser.m_strAutoTweetDesc.isEmpty()) {
								cResults.m_cUser.m_strAutoTweetDesc = String.format("%s%s%s https://poipiku.com/%d/ #%s",
										_TEX.T("EditSettingV.Twitter.Auto.AutoTxt"),
										cResults.m_cUser.m_strNickName,
										_TEX.T("Twitter.UserAddition"),
										cResults.m_cUser.m_nUserId,
										_TEX.T("Common.Title"));
							}%>
							<textarea id="AutoTweetTxt" class="SettingBodyTxt" rows="6" onkeyup="DispAutoTweetCharNum()" maxlength="100"><%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strAutoTweetDesc)%></textarea>
						</div>
						<div class="SettingBodyCmd">
							<div id="AutoTweetTxtNum" class="RegistMessage" >100</div>
						</div>
						<div class="SettingBodyCmd">
							<%=_TEX.T("EditSettingV.Twitter.Auto.ThumbNum")%>&nbsp;
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="AutoTweetThumb" class="onoffswitch-checkbox" id="AutoTweetThumb" value="1" <%if(cResults.m_cUser.m_nAutoTweetThumbNum>0){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AutoTweetThumb">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
						</div>
						<div class="SettingBodyCmd">
							<div class="RegistMessage" ></div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateAutoTweet()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>
				<%}%>

				<%if(cResults.m_cUser.m_strEmail.contains("@")) {%>
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Email.Address")%></div>
					<div class="SettingBody">
						<input id="EM" class="SettingBodyTxt" type="text" value="<%=Common.ToStringHtmlTextarea(cResults.m_cUser.m_strEmail)%>" />
						<div class="SettingBodyCmd">
							<div id="MailAdressMessage" class="RegistMessage" style="color: red;"><%=strEmailState%></div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdateEmailAddress()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Password")%></div>
					<div class="SettingBody">
						<div class="SettingBodyTxt" style="margin-top: 10px;">
							<%=_TEX.T("EditSettingV.Password.CurrentPassword")%>
						</div>
						<input id="PW" class="SettingBodyTxt" type="password" />
						<div class="SettingBodyTxt" style="margin-top: 10px;">
							<%=_TEX.T("EditSettingV.Password.NewPassword")%>
						</div>
						<input id="PW1" class="SettingBodyTxt" type="password" />
						<div class="SettingBodyTxt" style="margin-top: 10px;">
							<%=_TEX.T("EditSettingV.Password.NewPasswordConfirm")%>
						</div>
						<input id="PW2" class="SettingBodyTxt" type="password" />
						<div class="SettingBodyCmd" style="margin-top: 20px;">
							<div id="UserNameMessage" class="RegistMessage" style="color: red;">&nbsp;</div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="UpdatePassword()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
						</div>
					</div>
				</div>
				<%}%>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.Logout")%></div>
					<div class="SettingBody">
						<div class="SettingBodyCmd ">
							<div class="RegistMessage" ></div>
							<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="Logout()"><%=_TEX.T("EditSettingV.Logout")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("EditSettingV.DeleteAccount")%></div>
					<div class="SettingBody">
						<%=_TEX.T("EditSettingV.DeleteAccount.Message")%>
						<div class="SettingBodyCmd">
							<div id="DeleteAccountMessage" class="RegistMessage" >
								<label>
									<input id="CheckDeregistCheckBox" type="checkbox" onclick="CheckDeregist_checkbox();" />
									<%=_TEX.T("EditSettingV.DeleteAccount.CheckButton")%>
								</label>
							</div>
							<a id="CheckDeregist" class="BtnBase SettingBodyCmdRegist Disabled" onclick="CheckDeregist()"><%=_TEX.T("EditSettingV.DeleteAccount.Button")%></a>
						</div>
					</div>
				</div>

				<div class="SettingListItem" style="margin-bottom: 15px; border-bottom: none;">
					<div class="SettingListTitle"><%=_TEX.T("HowTo.Title")%>/<%=_TEX.T("Footer.Term")%>/<%=_TEX.T("Footer.Information")%></div>
					<div class="SettingBody">
						<a href="/how_to/TopPcV.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("HowTo.Title")%></a><br />
						<a href="/RulePcS.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.Term")%></a><br />
						<a href="/GuideLinePcV.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.GuideLine")%></a><br />
						<a href="/PrivacyPolicyPcS.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.PrivacyPolicy")%></a><br />
						<a href="https://twitter.com/pipajp" style="font-size: 14px; text-decoration: underline;" target="_blank"><%=_TEX.T("Footer.Information")%></a><br />
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>